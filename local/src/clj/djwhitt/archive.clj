(ns djwhitt.archive
  (:require [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [clojure.string :as str])
  (:import [java.text SimpleDateFormat]
           [java.util Date]))

(def default-remotes ["s3" "rsync-dot-net"])

(defn default-config []
  (let [annex-dir (str (fs/home) "/Annex")]
    {:annex-dir annex-dir
     :inbox-dir (str annex-dir "/inbox")
     :remotes default-remotes}))

(defn usage-message []
  "Usage: a [--dry-run] <file>")

(defn date-string
  ([] (date-string (Date.)))
  ([date]
   (.format (SimpleDateFormat. "yyyyMMdd") date)))

(defn format-cmd [args]
  (str/join " " (map pr-str args)))

(defn parse-args [args]
  (loop [remaining args
         opts {:dry-run false :file nil}]
    (if-let [arg (first remaining)]
      (cond
        (= arg "--dry-run")
        (recur (rest remaining) (assoc opts :dry-run true))

        (str/starts-with? arg "-")
        {:error (str "Unknown option: " arg)}

        (:file opts)
        {:error "Usage error: expected exactly one file argument."}

        :else
        (recur (rest remaining) (assoc opts :file arg)))
      opts)))

(defn validate-opts [{:keys [error file] :as opts}]
  (cond
    error opts
    file opts
    :else {:error (usage-message)}))

(defn file-parts [file]
  (let [basename (str (fs/file-name file))
        last-dot (.lastIndexOf basename ".")]
    {:basename basename
     :stem (if (pos? last-dot) (subs basename 0 last-dot) basename)
     :ext (if (pos? last-dot) (subs basename last-dot) "")}))

(defn archive-entry [{:keys [file inbox-dir date sha256]}]
  (let [{:keys [basename stem ext]} (file-parts file)
        archive-name (str date "-" stem "-" sha256 ext)]
    {:basename basename
     :stem stem
     :ext ext
     :date date
     :sha256 sha256
     :archive-name archive-name
     :archive-path (str inbox-dir "/" archive-name)}))

(defn commit-message [{:keys [basename]}]
  (str "archive: " basename))

(defn duplicate-patterns [hash]
  [(str "*-" hash)
   (str "*-" hash ".*")])

(defn find-duplicate [glob-fn inbox-dir hash]
  (->> (duplicate-patterns hash)
       (mapcat #(glob-fn inbox-dir %))
       (map str)
       distinct
       sort
       first))

(defn result
  ([status exit-code]
   (result status exit-code [] []))
  ([status exit-code messages warnings]
   {:status status
    :exit-code exit-code
    :messages (vec messages)
    :warnings (vec warnings)}))

(defn add-message [res message]
  (update res :messages conj message))

(defn add-warning [res warning]
  (update res :warnings conj warning))

(defn error-result [message]
  (result :error 1 [message] []))

(defn duplicate-result [message details]
  (merge (result :duplicate 0 [message] []) details))

(defn ok-result [details]
  (merge (result :ok 0 [] []) details))

(defn format-command-failure [{:keys [dir result]} args]
  (let [stdout (not-empty (:out result))
        stderr (not-empty (:err result))]
    (str "Command failed"
         (when dir (str " in '" dir "'"))
         ": "
         (format-cmd args)
         (when stdout (str "\nstdout:\n" stdout))
         (when stderr (str "\nstderr:\n" stderr)))))

(defn cmd! [{:keys [dir out err] :or {out :string err :string}} args]
  (let [result (apply shell (merge {:continue true :out out :err err}
                                   (when dir {:dir dir}))
                      args)]
    (when-not (zero? (:exit result))
      (throw (ex-info (format-command-failure {:dir dir :result result} args)
                      {:args args :dir dir :result result})))
    result))

(defn sha256sum [run! file]
  (-> (run! {} ["sha256sum" file])
      :out
      str/trim
      (str/split #"\s+")
      first))

(defn real-effects []
  {:directory? fs/directory?
   :regular-file? fs/regular-file?
   :create-dirs! fs/create-dirs
   :glob (fn [dir pattern] (fs/glob dir pattern))
   :date-string date-string
   :run! cmd!
   :sha256sum (fn [file] (sha256sum cmd! file))})

(defn ensure-annex-repo! [{:keys [directory? run!]} {:keys [annex-dir remotes]}]
  (when-not (directory? annex-dir)
    (throw (ex-info (str "Error: annex directory '" annex-dir "' does not exist.")
                    {:annex-dir annex-dir})))

  (run! {:dir annex-dir} ["git" "rev-parse" "--is-inside-work-tree"])
  (run! {:dir annex-dir} ["git" "annex" "info"])

  (doseq [remote remotes]
    (run! {:dir annex-dir} ["git" "remote" "get-url" remote])))

(defn ensure-inbox-dir! [{:keys [directory? create-dirs!]} {:keys [inbox-dir]} {:keys [dry-run] :as res}]
  (if (directory? inbox-dir)
    res
    (if dry-run
      (add-message res (str "[dry-run] would create directory '" inbox-dir "'"))
      (do
        (create-dirs! inbox-dir)
        res))))

(defn run-mutating-command! [{:keys [run!]} {:keys [dry-run] :as res} opts args]
  (if dry-run
    (add-message res
                 (str "[dry-run] would run"
                      (when-let [dir (:dir opts)] (str " in '" dir "'"))
                      ": "
                      (format-cmd args)))
    (do
      (run! opts args)
      res)))

(defn copy-to-remotes! [effects {:keys [annex-dir remotes]} {:keys [archive-name] :as archive} {:keys [dry-run] :as res}]
  (reduce
   (fn [current remote]
     (try
       (run-mutating-command! effects current {:dir annex-dir}
                              ["git" "annex" "copy" archive-name "--to" remote])
       (catch Exception _
         (add-warning current (str "Warning: failed to copy to " remote ".")))))
   res
   remotes))

(defn run-archive! [effects {:keys [inbox-dir annex-dir] :as config} {:keys [dry-run file] :as opts}]
  (cond
    (:error opts)
    (error-result (:error opts))

    (nil? file)
    (error-result (usage-message))

    (not ((:regular-file? effects) file))
    (error-result (str "Error: '" file "' does not exist or is not a regular file."))

    :else
    (try
      (ensure-annex-repo! effects config)
      (let [res (ensure-inbox-dir! effects config (assoc (ok-result {:dry-run dry-run}) :dry-run dry-run))
            sha256 ((:sha256sum effects) file)
            archive (archive-entry {:file file
                                    :inbox-dir inbox-dir
                                    :date ((:date-string effects))
                                    :sha256 sha256})
            existing (find-duplicate (:glob effects) inbox-dir sha256)]
        (if existing
          (duplicate-result
           (str "A file with hash '" sha256 "' is already archived at '" existing "'. Skipping.")
           {:dry-run dry-run
            :sha256 sha256
            :existing-path existing
            :archive-name (:archive-name archive)
            :archive-path (:archive-path archive)})
          (let [res (-> res
                        (assoc :sha256 sha256
                               :basename (:basename archive)
                               :archive-name (:archive-name archive)
                               :archive-path (:archive-path archive))
                        (add-message (str (if dry-run "[dry-run] Would archive '" "Archiving '")
                                          file
                                          "' to '"
                                          (:archive-path archive)
                                          "'..."))
                        (add-message (str "SHA256: " sha256)))
                res (run-mutating-command! effects res {} ["mv" file (:archive-path archive)])
                res (run-mutating-command! effects res {:dir inbox-dir}
                                          ["git" "annex" "add" (:archive-name archive)])
                res (run-mutating-command! effects res {:dir annex-dir}
                                          ["git" "commit" "-m" (commit-message archive)])
                res (copy-to-remotes! effects config archive res)
                res (run-mutating-command! effects res {:dir annex-dir} ["git" "annex" "sync"])
                res (run-mutating-command! effects res {:dir annex-dir} ["git" "push"])]
            (add-message res
                         (str (if dry-run "[dry-run] Done. File would be archived as '"
                                  "Done. File archived as '")
                              (:archive-name archive)
                              "'.")))))
      (catch Exception e
        (error-result (.getMessage e))))))

(defn emit-result! [{:keys [messages warnings]}]
  (binding [*out* *err*]
    (doseq [message messages]
      (println message))
    (doseq [warning warnings]
      (println warning))))

(defn -main [& args]
  (let [opts (-> args
                 parse-args
                 validate-opts)
        res (run-archive! (real-effects) (default-config) opts)]
    (emit-result! res)
    (:exit-code res)))
