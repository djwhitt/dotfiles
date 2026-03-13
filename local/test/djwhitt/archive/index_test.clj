(ns djwhitt.archive.index-test
  (:require [babashka.fs :as fs]
            [clojure.test :refer [deftest is testing]]
            [djwhitt.archive.index :as index]))

(defn temp-db-path []
  (str (fs/create-temp-file {:prefix "archive-index-" :suffix ".db"})))

(deftest ensure-schema-test
  (let [db-path (temp-db-path)]
    (index/ensure-schema! db-path)
    (is (fs/exists? db-path))
    (is (nil? (index/document-by-sha256 db-path "missing")))))

(deftest upsert-and-search-test
  (let [db-path (temp-db-path)]
    (index/upsert-document! db-path
                            {:sha256 "abc123"
                             :archive-name "20260312-report-abc123.pdf"
                             :archive-path "/annex/inbox/20260312-report-abc123.pdf"
                             :basename "report.pdf"
                             :mime-type "application/pdf"
                             :extractor "pdftotext"
                             :content "Quarterly revenue increased significantly."
                             :extraction-status :ok})

    (testing "stores metadata"
      (is (= {:sha256 "abc123"
              :archive_name "20260312-report-abc123.pdf"}
             (select-keys (index/document-by-sha256 db-path "abc123") [:sha256 :archive_name]))))

    (testing "searches indexed content"
      (is (= [{:archive_path "/annex/inbox/20260312-report-abc123.pdf"
               :basename "report.pdf"}]
             (mapv #(select-keys % [:archive_path :basename])
                   (index/search db-path "revenue" 10)))))))

(deftest upsert-replaces-content-test
  (let [db-path (temp-db-path)]
    (index/upsert-document! db-path
                            {:sha256 "abc123"
                             :archive-name "20260312-report-abc123.pdf"
                             :archive-path "/annex/inbox/20260312-report-abc123.pdf"
                             :basename "report.pdf"
                             :mime-type "application/pdf"
                             :extractor "pdftotext"
                             :content "old term"
                             :extraction-status :ok})
    (index/upsert-document! db-path
                            {:sha256 "abc123"
                             :archive-name "20260312-report-abc123.pdf"
                             :archive-path "/annex/inbox/20260312-report-abc123.pdf"
                             :basename "report.pdf"
                             :mime-type "application/pdf"
                             :extractor "pdftotext"
                             :content "new term"
                             :extraction-status :ok})

    (is (empty? (index/search db-path "old" 10)))
    (is (= 1 (count (index/search db-path "new" 10))))))

(deftest metadata-only-document-test
  (let [db-path (temp-db-path)]
    (index/upsert-document! db-path
                            {:sha256 "abc123"
                             :archive-name "20260312-image-abc123.png"
                             :archive-path "/annex/inbox/20260312-image-abc123.png"
                             :basename "image.png"
                             :mime-type "image/png"
                             :extractor nil
                             :content nil
                             :extraction-status :unsupported
                             :extraction-error "No extractor for image/png"})

    (let [doc (index/document-by-sha256 db-path "abc123")]
      (is (= "unsupported" (:extraction_status doc)))
      (is (= 0 (:content_chars doc)))
      (is (empty? (index/search db-path "image" 10))))))

(deftest sql-escaping-test
  (let [db-path (temp-db-path)]
    (index/upsert-document! db-path
                            {:sha256 "quote123"
                             :archive-name "20260312-notes-quote123.txt"
                             :archive-path "/annex/inbox/20260312-notes-quote123.txt"
                             :basename "notes.txt"
                             :mime-type "text/plain"
                             :extractor "slurp"
                             :content "don't panic"
                             :extraction-status :ok
                             :extraction-error "couldn't reproduce"})

    (is (= "couldn't reproduce"
           (:extraction_error (index/document-by-sha256 db-path "quote123"))))
    (is (= 1 (count (index/search db-path "panic" 10))))))
