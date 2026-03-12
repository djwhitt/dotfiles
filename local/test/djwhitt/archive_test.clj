(ns djwhitt.archive-test
  (:require [clojure.test :refer [deftest is testing]]
            [djwhitt.archive :as archive]))

(defn recording-runner [calls]
  (fn [opts args]
    (swap! calls conj {:opts opts :args args})
    {:exit 0 :out "" :err ""}))

(defn base-effects
  ([] (base-effects []))
  ([glob-results]
   {:directory? (constantly true)
    :regular-file? (constantly true)
    :create-dirs! (fn [_] nil)
    :glob (fn [_ pattern] (get glob-results pattern []))
    :date-string (constantly "20260312")
    :sha256sum (constantly "abc123")
    :run! (fn [_ _] {:exit 0 :out "" :err ""})}))

(deftest parse-args-test
  (testing "parses dry-run and file"
    (is (= {:dry-run true :file "/tmp/file.txt"}
           (archive/parse-args ["--dry-run" "/tmp/file.txt"]))))

  (testing "rejects unknown options"
    (is (= {:error "Unknown option: --wat"}
           (archive/parse-args ["--wat"]))))

  (testing "rejects extra positional args"
    (is (= {:error "Usage error: expected exactly one file argument."}
           (archive/parse-args ["one" "two"])))))

(deftest validate-opts-test
  (testing "adds usage error when file is missing"
    (is (= {:error (archive/usage-message)}
           (archive/validate-opts {:dry-run false}))))

  (testing "preserves an existing parse error"
    (is (= {:error "boom"}
           (archive/validate-opts {:error "boom"})))))

(deftest file-parts-and-archive-entry-test
  (testing "splits file parts and builds archive paths"
    (is (= {:basename "report.pdf"
            :stem "report"
            :ext ".pdf"
            :date "20260312"
            :sha256 "abc123"
            :archive-name "20260312-report-abc123.pdf"
            :archive-path "/tmp/inbox/20260312-report-abc123.pdf"}
           (archive/archive-entry {:file "/tmp/report.pdf"
                                   :inbox-dir "/tmp/inbox"
                                   :date "20260312"
                                   :sha256 "abc123"}))))

  (testing "handles extensionless files"
    (is (= {:basename "README"
            :stem "README"
            :ext ""}
           (archive/file-parts "/tmp/README")))))

(deftest find-duplicate-test
  (testing "finds extensionless duplicates"
    (is (= "/tmp/inbox/20260312-README-deadbeef"
           (archive/find-duplicate
            (fn [_ pattern]
              (case pattern
                "*-deadbeef" ["/tmp/inbox/20260312-README-deadbeef"]
                "*-deadbeef.*" []
                []))
            "/tmp/inbox"
            "deadbeef"))))

  (testing "finds duplicates with extensions"
    (is (= "/tmp/inbox/20260312-report-deadbeef.pdf"
           (archive/find-duplicate
            (fn [_ pattern]
              (case pattern
                "*-deadbeef" []
                "*-deadbeef.*" ["/tmp/inbox/20260312-report-deadbeef.pdf"]
                []))
            "/tmp/inbox"
            "deadbeef")))))

(deftest run-archive-dry-run-test
  (let [calls (atom [])
        effects (assoc (base-effects)
                       :run! (recording-runner calls))
        result (archive/run-archive! effects
                                     {:annex-dir "/annex"
                                      :inbox-dir "/annex/inbox"
                                      :remotes ["s3" "rsync-dot-net"]}
                                     {:dry-run true :file "/tmp/report.pdf"})]
    (testing "returns a successful dry-run result"
      (is (= :ok (:status result)))
      (is (= 0 (:exit-code result)))
      (is (= "20260312-report-abc123.pdf" (:archive-name result)))
      (is (= "/annex/inbox/20260312-report-abc123.pdf" (:archive-path result)))
      (is (= "abc123" (:sha256 result))))

    (testing "emits the expected dry-run messages"
      (is (= ["[dry-run] Would archive '/tmp/report.pdf' to '/annex/inbox/20260312-report-abc123.pdf'..."
              "SHA256: abc123"
              "[dry-run] would run: \"mv\" \"/tmp/report.pdf\" \"/annex/inbox/20260312-report-abc123.pdf\""
              "[dry-run] would run in '/annex/inbox': \"git\" \"annex\" \"add\" \"20260312-report-abc123.pdf\""
              "[dry-run] would run in '/annex': \"git\" \"commit\" \"-m\" \"archive: report.pdf\""
              "[dry-run] would run in '/annex': \"git\" \"annex\" \"copy\" \"20260312-report-abc123.pdf\" \"--to\" \"s3\""
              "[dry-run] would run in '/annex': \"git\" \"annex\" \"copy\" \"20260312-report-abc123.pdf\" \"--to\" \"rsync-dot-net\""
              "[dry-run] would run in '/annex': \"git\" \"annex\" \"sync\""
              "[dry-run] would run in '/annex': \"git\" \"push\""
              "[dry-run] Done. File would be archived as '20260312-report-abc123.pdf'."]
             (:messages result))))

    (testing "only validation commands hit the runner in dry-run mode"
      (is (= [{:opts {:dir "/annex"}
               :args ["git" "rev-parse" "--is-inside-work-tree"]}
              {:opts {:dir "/annex"}
               :args ["git" "annex" "info"]}
              {:opts {:dir "/annex"}
               :args ["git" "remote" "get-url" "s3"]}
              {:opts {:dir "/annex"}
               :args ["git" "remote" "get-url" "rsync-dot-net"]}]
             @calls)))))

(deftest run-archive-duplicate-test
  (let [calls (atom [])
        effects (-> (base-effects {"*-abc123" ["/annex/inbox/20260312-report-abc123"]
                                   "*-abc123.*" []})
                    (assoc :run! (recording-runner calls)))
        result (archive/run-archive! effects
                                     {:annex-dir "/annex"
                                      :inbox-dir "/annex/inbox"
                                      :remotes ["s3"]}
                                     {:dry-run false :file "/tmp/report"})]
    (is (= :duplicate (:status result)))
    (is (= 0 (:exit-code result)))
    (is (= "/annex/inbox/20260312-report-abc123" (:existing-path result)))
    (is (= ["A file with hash 'abc123' is already archived at '/annex/inbox/20260312-report-abc123'. Skipping."]
           (:messages result)))
    (is (= [{:opts {:dir "/annex"}
             :args ["git" "rev-parse" "--is-inside-work-tree"]}
            {:opts {:dir "/annex"}
             :args ["git" "annex" "info"]}
            {:opts {:dir "/annex"}
             :args ["git" "remote" "get-url" "s3"]}]
           @calls))))

(deftest run-archive-live-command-order-test
  (let [calls (atom [])
        effects (assoc (base-effects)
                       :run! (recording-runner calls))
        result (archive/run-archive! effects
                                     {:annex-dir "/annex"
                                      :inbox-dir "/annex/inbox"
                                      :remotes ["s3" "rsync-dot-net"]}
                                     {:dry-run false :file "/tmp/report.pdf"})]
    (is (= :ok (:status result)))
    (is (= [{:opts {:dir "/annex"}
             :args ["git" "rev-parse" "--is-inside-work-tree"]}
            {:opts {:dir "/annex"}
             :args ["git" "annex" "info"]}
            {:opts {:dir "/annex"}
             :args ["git" "remote" "get-url" "s3"]}
            {:opts {:dir "/annex"}
             :args ["git" "remote" "get-url" "rsync-dot-net"]}
            {:opts {}
             :args ["mv" "/tmp/report.pdf" "/annex/inbox/20260312-report-abc123.pdf"]}
            {:opts {:dir "/annex/inbox"}
             :args ["git" "annex" "add" "20260312-report-abc123.pdf"]}
            {:opts {:dir "/annex"}
             :args ["git" "commit" "-m" "archive: report.pdf"]}
            {:opts {:dir "/annex"}
             :args ["git" "annex" "copy" "20260312-report-abc123.pdf" "--to" "s3"]}
            {:opts {:dir "/annex"}
             :args ["git" "annex" "copy" "20260312-report-abc123.pdf" "--to" "rsync-dot-net"]}
            {:opts {:dir "/annex"}
             :args ["git" "annex" "sync"]}
            {:opts {:dir "/annex"}
             :args ["git" "push"]}]
           @calls))))

(deftest run-archive-error-test
  (let [effects (assoc (base-effects)
                       :regular-file? (constantly false))
        result (archive/run-archive! effects
                                     {:annex-dir "/annex"
                                      :inbox-dir "/annex/inbox"
                                      :remotes ["s3"]}
                                     {:dry-run false :file "/tmp/missing.txt"})]
    (is (= :error (:status result)))
    (is (= 1 (:exit-code result)))
    (is (= ["Error: '/tmp/missing.txt' does not exist or is not a regular file."]
           (:messages result)))))
