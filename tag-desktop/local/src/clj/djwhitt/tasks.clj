(ns djwhitt.tasks
  (:require [babashka.http-client :as http]
            [babashka.process :refer [shell]]
            [clojure.java.io :as io]
            [cheshire.core :as json]
            [clojure.pprint :refer [pprint]]
            [malli.core :as m]))

(def og-pwd (System/getenv "ORIGINAL_PWD"))

(defn ping []
  (println "PONG!"))

(def get-auth-token
  ;; TODO: rename script to nocodb-auth-token
  (memoize #(shell "nocodb-api-key")))

(def nocodb-base-url "https://nocodb.spcom.org")
(def documents-table-id "mep1zsd8cug5el7")

(defn upload-file [file-path]
  (let [file-path (str og-pwd "/" file-path)
        response (http/post (str nocodb-base-url "/api/v2/storage/upload")
                            {:headers {"xc-token" (get-auth-token)}
                             :multipart [{:name "file"
                                          :content (io/file file-path)}]})]
    (if (= 200 (:status response))
      (-> response :body (json/parse-string true) first)
      (throw (Exception. (str "Failed to upload file: " (:body response)))))))

(defn add-row-with-attachment [attachment]
  (let [row-data {"Title" "Sample Title"
                  "File" [attachment]}
        response (http/post (str nocodb-base-url
                                 "/api/v2/tables/"
                                 documents-table-id
                                 "/records")
                            {:headers {"xc-token" (get-auth-token)
                                       "Content-Type" "application/json"}
                             :body (json/generate-string row-data)})]
    (if (= 200 (:status response))
      (-> response :body (json/parse-string true))
      (throw (Exception. (str "Failed to add row: " (:body response)))))))

(defn upload-nocodb-file []
  (let [file (first *command-line-args*)]
    (if (not file)
      (throw (Exception. "File path is required"))
      (pprint (upload-file file)))))

(defn archive-document []
  (let [file (first *command-line-args*)]
    (if (not file)
      (throw (Exception. "File path is required"))
      (let [file-metadata (upload-file file)]
        (pprint (add-row-with-attachment file-metadata))))))
