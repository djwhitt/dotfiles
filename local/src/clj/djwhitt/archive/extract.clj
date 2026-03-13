(ns djwhitt.archive.extract
  (:require [babashka.process :refer [shell]]
            [clojure.string :as str]))

(def max-content-chars 1000000)

(def text-extension->mime
  {"txt" "text/plain"
   "md" "text/markdown"
   "markdown" "text/markdown"
   "org" "text/plain"
   "json" "application/json"
   "csv" "text/csv"
   "tsv" "text/tab-separated-values"
   "edn" "application/edn"
   "clj" "text/plain"
   "cljs" "text/plain"
   "cljc" "text/plain"
   "sql" "text/plain"
   "xml" "application/xml"
   "html" "text/html"
   "htm" "text/html"})

(def text-mime-types
  #{"application/json"
    "application/edn"
    "application/xml"
    "application/x-edn"})

(defn file-extension [file]
  (let [name (str file)
        idx (.lastIndexOf name ".")]
    (when (pos? idx)
      (subs name (inc idx)))))

(defn extension-mime-type [file]
  (some-> file file-extension str/lower-case text-extension->mime))

(defn run-command! [args]
  (let [result (apply shell {:continue true :out :string :err :string} args)]
    (when-not (zero? (:exit result))
      (throw (ex-info (str "Command failed: " (str/join " " (map pr-str args))
                           (when-let [stderr (not-empty (:err result))]
                             (str "\nstderr:\n" stderr)))
                      {:args args :result result})))
    result))

(defn mime-type
  ([file] (mime-type run-command! file))
  ([run! file]
   (try
     (-> (run! ["file" "-L" "--mime-type" "-b" file])
         :out
         str/trim
         not-empty)
     (catch Exception _
       nil))))

(defn text-file? [mime-type file]
  (or (and mime-type (str/starts-with? mime-type "text/"))
      (contains? text-mime-types mime-type)
      (some? (extension-mime-type file))))

(defn truncate-content [content]
  (let [content (or content "")]
    {:content (if (> (count content) max-content-chars)
                (subs content 0 max-content-chars)
                content)
     :truncated? (> (count content) max-content-chars)}))

(defn- extraction-result [{:keys [status mime-type extractor content error]}]
  (let [{:keys [content truncated?]} (truncate-content content)]
    {:status status
     :mime-type mime-type
     :extractor extractor
     :content content
     :error error
     :truncated? truncated?}))

(defn- text-result [file mime-type]
  (let [content (slurp file)]
    (extraction-result {:status (if (str/blank? content) :empty :ok)
                        :mime-type mime-type
                        :extractor "slurp"
                        :content content})))

(defn- pdf-result [run! file mime-type]
  (let [content (-> (run! ["pdftotext" "-layout" "-q" file "-"])
                    :out)]
    (extraction-result {:status (if (str/blank? content) :empty :ok)
                        :mime-type mime-type
                        :extractor "pdftotext"
                        :content content})))

(defn extract-text
  ([file] (extract-text {} file))
  ([{:keys [run-command-fn mime-type-fn]
     :or {run-command-fn run-command!
          mime-type-fn (fn [path] (mime-type run-command-fn path))}}
    file]
   (let [mime-type (or (mime-type-fn file)
                       (extension-mime-type file))]
     (try
       (cond
         (text-file? mime-type file)
         (text-result file (or mime-type (extension-mime-type file) "text/plain"))

         (= mime-type "application/pdf")
         (pdf-result run-command-fn file mime-type)

         :else
         {:status :unsupported
          :mime-type mime-type
          :extractor nil
          :content nil
          :error (str "No extractor for " (or mime-type "unknown MIME type"))
          :truncated? false})
       (catch Exception e
         {:status :error
          :mime-type mime-type
          :extractor (cond
                       (= mime-type "application/pdf") "pdftotext"
                       (text-file? mime-type file) "slurp"
                       :else nil)
          :content nil
          :error (.getMessage e)
          :truncated? false})))))
