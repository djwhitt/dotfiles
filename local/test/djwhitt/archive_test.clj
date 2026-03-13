(ns djwhitt.archive-test
  (:require [clojure.string :as str]
            [clojure.test :refer [deftest is testing]]
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
    :run! (fn [_ _] {:exit 0 :out "" :err ""})
    :extract-text (constantly {:status :ok
                               :mime-type "text/plain"
                               :extractor "slurp"
                               :content "indexed content"
                               :error nil
                               :truncated? false})
    :upsert-document! (fn [_ _] nil)
    :search-index (fn [_ _ _] [])}))

(def config
  {:annex-dir "/annex"
   :inbox-dir "/annex/inbox"
   :index-db-path "/tmp/archive-index.db"
   :remotes ["s3" "rsync-dot-net"]})

(deftest parse-args-test
  (testing "parses archive dry-run and file"
    (is (= {:command :archive :dry-run true :file "/tmp/file.txt" :query nil}
           (archive/parse-args ["--dry-run" "/tmp/file.txt"]))))

  (testing "parses reindex subcommand"
    (is (= {:command :reindex :dry-run false :file nil :query nil}
           (archive/parse-args ["reindex"]))))

  (testing "parses dry-run reindex subcommand"
    (is (= {:command :reindex :dry-run true :file nil :query nil}
           (archive/parse-args ["reindex" "--dry-run"]))))

  (testing "parses search subcommand"
    (is (= {:command :search :dry-run false :file nil :query "revenue"}
           (archive/parse-args ["search" "revenue"]))))

  (testing "rejects unknown options"
    (is (= {:error "Unknown option: --wat"}
           (archive/parse-args ["--wat"]))))

  (testing "rejects extra positional args for archive"
    (is (= {:error "Usage error: expected exactly one file argument."}
           (archive/parse-args ["one" "two"]))))

  (testing "rejects extra positional args for reindex"
    (is (= {:error "Usage error: reindex does not accept positional arguments."}
           (archive/parse-args ["reindex" "extra"]))))

  (testing "rejects extra positional args for search"
    (is (= {:error "Usage error: expected exactly one query argument."}
           (archive/parse-args ["search" "one" "two"])))))

(deftest validate-opts-test
  (testing "adds usage error when archive file is missing"
    (is (= {:error (archive/usage-message)}
           (archive/validate-opts {:command :archive :dry-run false :query nil}))))

  (testing "allows reindex with no file"
    (is (= {:command :reindex :dry-run false :file nil :query nil}
           (archive/validate-opts {:command :reindex :dry-run false :file nil :query nil}))))

  (testing "allows search with a query"
    (is (= {:command :search :dry-run false :file nil :query "revenue"}
           (archive/validate-opts {:command :search :dry-run false :file nil :query "revenue"}))))

  (testing "rejects dry-run with search"
    (is (= {:error "Usage error: --dry-run is not supported with search."}
           (archive/validate-opts {:command :search :dry-run true :file nil :query "revenue"}))))

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

(deftest original-basename-test
  (testing "restores the original basename for files with extensions"
    (is (= "report.pdf"
           (archive/original-basename "20260312-report-abc123.pdf" "abc123"))))

  (testing "restores the original basename for extensionless files"
    (is (= "README"
           (archive/original-basename "20260312-README-abc123" "abc123"))))

  (testing "restores the original basename for legacy archive names"
    (is (= "Dataandreality.pdf"
           (archive/original-basename "20231008-sha256-3b9573c12c72b15471dc18109bbfda70665da31804255032df2ea731871861ec-Dataandreality.pdf"
                                      "3b9573c12c72b15471dc18109bbfda70665da31804255032df2ea731871861ec"))))

  (testing "falls back to the archive name when the format does not match"
    (is (= "report.pdf"
           (archive/original-basename "report.pdf" "abc123")))))

(deftest format-search-result-test
  (is (= "report.pdf\n  /annex/inbox/20260312-report-abc123.pdf\n  Quarterly [revenue] increased."
         (archive/format-search-result {:basename "report.pdf"
                                        :archive_path "/annex/inbox/20260312-report-abc123.pdf"
                                        :snippet "Quarterly [revenue] increased."})))
  (is (= "report.pdf\n  /annex/inbox/20260312-report-abc123.pdf"
         (archive/format-search-result {:basename "report.pdf"
                                        :archive_path "/annex/inbox/20260312-report-abc123.pdf"
                                        :snippet nil}))))

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
        indexed (atom [])
        effects (assoc (base-effects)
                       :run! (recording-runner calls)
                       :extract-text (fn [_]
                                       (swap! indexed conj :extract-called)
                                       {:status :ok
                                        :mime-type "text/plain"
                                        :extractor "slurp"
                                        :content "indexed content"
                                        :error nil
                                        :truncated? false})
                       :upsert-document! (fn [_ _]
                                           (swap! indexed conj :upsert-called)))
        result (archive/run-archive! effects
                                     config
                                     {:command :archive :dry-run true :file "/tmp/report.pdf" :query nil})]
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
              "[dry-run] would index '/annex/inbox/20260312-report-abc123.pdf' into '/tmp/archive-index.db'"
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
             @calls)))

    (testing "dry-run does not extract or upsert index data"
      (is (empty? @indexed)))))

(deftest run-archive-duplicate-test
  (let [calls (atom [])
        effects (-> (base-effects {"*-abc123" ["/annex/inbox/20260312-report-abc123"]
                                   "*-abc123.*" []})
                    (assoc :run! (recording-runner calls)))
        result (archive/run-archive! effects
                                     (assoc config :remotes ["s3"])
                                     {:command :archive :dry-run false :file "/tmp/report" :query nil})]
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
        indexed (atom [])
        effects (assoc (base-effects)
                       :run! (recording-runner calls)
                       :extract-text (fn [path]
                                       (swap! indexed conj [:extract path])
                                       {:status :ok
                                        :mime-type "application/pdf"
                                        :extractor "pdftotext"
                                        :content "Quarterly revenue increased significantly."
                                        :error nil
                                        :truncated? false})
                       :upsert-document! (fn [db-path doc]
                                           (swap! indexed conj [:upsert db-path doc])))
        result (archive/run-archive! effects
                                     config
                                     {:command :archive :dry-run false :file "/tmp/report.pdf" :query nil})]
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
           @calls))
    (is (= [[:extract "/annex/inbox/20260312-report-abc123.pdf"]
            [:upsert "/tmp/archive-index.db"
             {:sha256 "abc123"
              :archive-name "20260312-report-abc123.pdf"
              :archive-path "/annex/inbox/20260312-report-abc123.pdf"
              :basename "report.pdf"
              :mime-type "application/pdf"
              :extractor "pdftotext"
              :content "Quarterly revenue increased significantly."
              :extraction-status :ok
              :extraction-error nil}]]
           @indexed))
    (is (= "Indexed '20260312-report-abc123.pdf' in '/tmp/archive-index.db' (status: ok)."
           (nth (:messages result) 2)))))

(deftest run-archive-index-warning-test
  (let [effects (assoc (base-effects)
                       :upsert-document! (fn [_ _]
                                           (throw (ex-info "db unavailable" {}))))
        result (archive/run-archive! effects
                                     config
                                     {:command :archive :dry-run false :file "/tmp/report.pdf" :query nil})]
    (is (= :ok (:status result)))
    (is (= ["Warning: failed to index '/annex/inbox/20260312-report-abc123.pdf': db unavailable"]
           (:warnings result)))))

(deftest run-reindex-dry-run-test
  (let [effects (assoc (base-effects {"*" ["/annex/inbox/20260312-report-abc123.pdf"
                                            "/annex/inbox/20260312-README-def456"]})
                       :sha256sum (fn [path]
                                    (if (str/ends-with? path ".pdf")
                                      "abc123"
                                      "def456"))
                       :extract-text (fn [_]
                                       (throw (ex-info "should not extract during dry-run" {})))
                       :upsert-document! (fn [_ _]
                                           (throw (ex-info "should not upsert during dry-run" {}))))
        result (archive/run-reindex! effects
                                     config
                                     {:command :reindex :dry-run true :file nil :query nil})]
    (is (= :ok (:status result)))
    (is (= ["[dry-run] Would reindex 2 archived files from '/annex/inbox' into '/tmp/archive-index.db'."
            "[dry-run] would index '/annex/inbox/20260312-README-def456' into '/tmp/archive-index.db'"
            "[dry-run] would index '/annex/inbox/20260312-report-abc123.pdf' into '/tmp/archive-index.db'"
            "[dry-run] Done. 2 archived files would be reindexed."]
           (:messages result)))))

(deftest run-reindex-live-test
  (let [indexed (atom [])
        effects (assoc (base-effects {"*" ["/annex/inbox/20260312-report-abc123.pdf"
                                            "/annex/inbox/20260312-README-def456"]})
                       :sha256sum (fn [path]
                                    (if (str/ends-with? path ".pdf")
                                      "abc123"
                                      "def456"))
                       :extract-text (fn [path]
                                       (if (str/ends-with? path ".pdf")
                                         {:status :ok
                                          :mime-type "application/pdf"
                                          :extractor "pdftotext"
                                          :content "Quarterly revenue increased significantly."
                                          :error nil
                                          :truncated? false}
                                         {:status :unsupported
                                          :mime-type nil
                                          :extractor nil
                                          :content nil
                                          :error "No extractor for unknown MIME type"
                                          :truncated? false}))
                       :upsert-document! (fn [db-path doc]
                                           (swap! indexed conj [db-path doc])))
        result (archive/run-reindex! effects
                                     config
                                     {:command :reindex :dry-run false :file nil :query nil})]
    (is (= :ok (:status result)))
    (is (= [["/tmp/archive-index.db"
             {:sha256 "def456"
              :archive-name "20260312-README-def456"
              :archive-path "/annex/inbox/20260312-README-def456"
              :basename "README"
              :mime-type nil
              :extractor nil
              :content nil
              :extraction-status :unsupported
              :extraction-error "No extractor for unknown MIME type"}]
            ["/tmp/archive-index.db"
             {:sha256 "abc123"
              :archive-name "20260312-report-abc123.pdf"
              :archive-path "/annex/inbox/20260312-report-abc123.pdf"
              :basename "report.pdf"
              :mime-type "application/pdf"
              :extractor "pdftotext"
              :content "Quarterly revenue increased significantly."
              :extraction-status :ok
              :extraction-error nil}]]
           @indexed))
    (is (= "Done. 2 archived files reindexed."
           (last (:messages result))))))

(deftest run-reindex-missing-inbox-test
  (let [effects (assoc (base-effects)
                       :directory? (fn [path]
                                     (not= path "/annex/inbox")))
        result (archive/run-reindex! effects
                                     config
                                     {:command :reindex :dry-run false :file nil :query nil})]
    (is (= :error (:status result)))
    (is (= ["Error: inbox directory '/annex/inbox' does not exist."]
           (:messages result)))))

(deftest run-reindex-file-warning-test
  (let [effects (assoc (base-effects {"*" ["/annex/inbox/20260312-report-abc123.pdf"]})
                       :sha256sum (fn [_]
                                    (throw (ex-info "sha failed" {}))))
        result (archive/run-reindex! effects
                                     config
                                     {:command :reindex :dry-run false :file nil :query nil})]
    (is (= :ok (:status result)))
    (is (= ["Warning: failed to prepare indexing for '/annex/inbox/20260312-report-abc123.pdf': sha failed"]
           (:warnings result)))))

(deftest run-search-test
  (let [effects (assoc (base-effects)
                       :search-index (fn [db-path query limit]
                                       (is (= "/tmp/archive-index.db" db-path))
                                       (is (= "revenue" query))
                                       (is (= 20 limit))
                                       [{:basename "report.pdf"
                                         :archive_path "/annex/inbox/20260312-report-abc123.pdf"
                                         :snippet "Quarterly [revenue] increased."}
                                        {:basename "summary.txt"
                                         :archive_path "/annex/inbox/20260312-summary-def456.txt"
                                         :snippet "[Revenue] summary."}]))
        result (archive/run-search! effects
                                    config
                                    {:command :search :dry-run false :file nil :query "revenue"})]
    (is (= :ok (:status result)))
    (is (= ["report.pdf\n  /annex/inbox/20260312-report-abc123.pdf\n  Quarterly [revenue] increased."
            "summary.txt\n  /annex/inbox/20260312-summary-def456.txt\n  [Revenue] summary."]
           (:messages result)))))

(deftest run-search-no-results-test
  (let [effects (assoc (base-effects)
                       :search-index (fn [_ _ _] []))
        result (archive/run-search! effects
                                    config
                                    {:command :search :dry-run false :file nil :query "missing"})]
    (is (= :ok (:status result)))
    (is (= ["No matches for 'missing'."]
           (:messages result)))))

(deftest run-search-error-test
  (let [effects (assoc (base-effects)
                       :search-index (fn [_ _ _]
                                       (throw (ex-info "db unavailable" {}))))
        result (archive/run-search! effects
                                    config
                                    {:command :search :dry-run false :file nil :query "revenue"})]
    (is (= :error (:status result)))
    (is (= ["db unavailable"]
           (:messages result)))))

(deftest run-archive-error-test
  (let [effects (assoc (base-effects)
                       :regular-file? (constantly false))
        result (archive/run-archive! effects
                                     (assoc config :remotes ["s3"])
                                     {:command :archive :dry-run false :file "/tmp/missing.txt" :query nil})]
    (is (= :error (:status result)))
    (is (= 1 (:exit-code result)))
    (is (= ["Error: '/tmp/missing.txt' does not exist or is not a regular file."]
           (:messages result)))))
