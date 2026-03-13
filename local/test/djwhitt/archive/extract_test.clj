(ns djwhitt.archive.extract-test
  (:require [babashka.fs :as fs]
            [clojure.test :refer [deftest is testing]]
            [djwhitt.archive.extract :as extract]))

(defn temp-file [suffix content]
  (let [path (str (fs/create-temp-file {:prefix "archive-extract-" :suffix suffix}))]
    (spit path content)
    path))

(deftest text-file-extraction-test
  (let [path (temp-file ".txt" "hello world")
        result (extract/extract-text path)]
    (is (= :ok (:status result)))
    (is (= "text/plain" (:mime-type result)))
    (is (= "slurp" (:extractor result)))
    (is (= "hello world" (:content result)))))

(deftest markdown-extension-fallback-test
  (let [path (temp-file ".md" "# heading")
        result (extract/extract-text {:mime-type-fn (constantly nil)} path)]
    (is (= :ok (:status result)))
    (is (= "text/markdown" (:mime-type result)))
    (is (= "slurp" (:extractor result)))
    (is (= "# heading" (:content result)))))

(deftest mime-type-follows-symlinks-test
  (let [path "/tmp/report.pdf"]
    (is (= "application/pdf"
           (extract/mime-type (fn [args]
                                (is (= ["file" "-L" "--mime-type" "-b" path] args))
                                {:out "application/pdf\n"})
                              path)))))

(deftest unsupported-file-test
  (let [path (temp-file ".png" "not really a png")
        result (extract/extract-text {:mime-type-fn (constantly "image/png")} path)]
    (is (= :unsupported (:status result)))
    (is (= "image/png" (:mime-type result)))
    (is (= "No extractor for image/png" (:error result)))))

(deftest pdf-extraction-runner-test
  (let [path (temp-file ".pdf" "%PDF")
        result (extract/extract-text {:mime-type-fn (constantly "application/pdf")
                                      :run-command-fn (fn [args]
                                                        (is (= ["pdftotext" "-layout" "-q" path "-"] args))
                                                        {:out "pdf text"})}
                                     path)]
    (is (= :ok (:status result)))
    (is (= "application/pdf" (:mime-type result)))
    (is (= "pdftotext" (:extractor result)))
    (is (= "pdf text" (:content result)))))
