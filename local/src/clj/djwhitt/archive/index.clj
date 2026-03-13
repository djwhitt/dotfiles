(ns djwhitt.archive.index
  (:require [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [cheshire.core :as json]
            [clojure.string :as str])
  (:import [java.time Instant]))

(def schema-version 1)

(defn default-db-path []
  (str (fs/path (fs/home) ".local" "share" "djwhitt" "archive" "index.db")))

(defn ensure-parent-dir! [db-path]
  (when-let [parent (fs/parent db-path)]
    (fs/create-dirs parent)))

(defn- format-cmd [args]
  (str/join " " (map pr-str args)))

(defn- run-command! [args input]
  (let [result (apply shell {:continue true :out :string :err :string :in input} args)]
    (when-not (zero? (:exit result))
      (throw (ex-info (str "Command failed: " (format-cmd args)
                           (when-let [stderr (not-empty (:err result))]
                             (str "\nstderr:\n" stderr)))
                      {:args args :input input :result result})))
    result))

(defn- sqlite3-args [db-path & extra-args]
  (vec (concat ["sqlite3"] extra-args [db-path])))

(defn- execute-sql! [db-path sql]
  (run-command! (sqlite3-args db-path) sql)
  nil)

(defn- query! [db-path sql]
  (let [result (run-command! (sqlite3-args db-path "-json") sql)
        output (str/trim (:out result))]
    (if (str/blank? output)
      []
      (json/parse-string output true))))

(defn- sql-literal [value]
  (cond
    (nil? value) "NULL"
    (string? value) (str "'" (str/replace value "'" "''") "'")
    (keyword? value) (sql-literal (name value))
    (true? value) "1"
    (false? value) "0"
    (number? value) (str value)
    :else (sql-literal (str value))))

(defn ensure-schema! [db-path]
  (ensure-parent-dir! db-path)
  (execute-sql! db-path
                (str "PRAGMA journal_mode=WAL;\n"
                     "PRAGMA foreign_keys=ON;\n"
                     "CREATE TABLE IF NOT EXISTS documents (\n"
                     "  sha256 TEXT PRIMARY KEY,\n"
                     "  archive_name TEXT NOT NULL,\n"
                     "  archive_path TEXT NOT NULL,\n"
                     "  basename TEXT NOT NULL,\n"
                     "  mime_type TEXT,\n"
                     "  extractor TEXT,\n"
                     "  indexed_at TEXT NOT NULL,\n"
                     "  content_chars INTEGER NOT NULL DEFAULT 0,\n"
                     "  extraction_status TEXT NOT NULL,\n"
                     "  extraction_error TEXT\n"
                     ");\n"
                     "CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts\n"
                     "USING fts5(\n"
                     "  sha256 UNINDEXED,\n"
                     "  basename,\n"
                     "  content,\n"
                     "  tokenize = 'porter unicode61'\n"
                     ");\n"
                     "PRAGMA user_version=" schema-version ";\n"))
  db-path)

(defn- content-chars [content]
  (count (or content "")))

(defn- extraction-status-name [status]
  (name (or status :unknown)))

(defn upsert-document!
  ([db-path document]
   (upsert-document! db-path document (str (Instant/now))))
  ([db-path {:keys [sha256 archive-name archive-path basename mime-type extractor content
                    extraction-status extraction-error]}
    indexed-at]
   (let [content (some-> content str)
         searchable? (not (str/blank? content))]
     (ensure-schema! db-path)
     (execute-sql! db-path
                   (str "BEGIN;\n"
                        "INSERT INTO documents\n"
                        "    (sha256, archive_name, archive_path, basename, mime_type, extractor,\n"
                        "     indexed_at, content_chars, extraction_status, extraction_error)\n"
                        "  VALUES ("
                        (str/join ", " [(sql-literal sha256)
                                         (sql-literal archive-name)
                                         (sql-literal archive-path)
                                         (sql-literal basename)
                                         (sql-literal mime-type)
                                         (sql-literal extractor)
                                         (sql-literal indexed-at)
                                         (sql-literal (content-chars content))
                                         (sql-literal (extraction-status-name extraction-status))
                                         (sql-literal extraction-error)])
                        ")\n"
                        "  ON CONFLICT(sha256) DO UPDATE SET\n"
                        "    archive_name = excluded.archive_name,\n"
                        "    archive_path = excluded.archive_path,\n"
                        "    basename = excluded.basename,\n"
                        "    mime_type = excluded.mime_type,\n"
                        "    extractor = excluded.extractor,\n"
                        "    indexed_at = excluded.indexed_at,\n"
                        "    content_chars = excluded.content_chars,\n"
                        "    extraction_status = excluded.extraction_status,\n"
                        "    extraction_error = excluded.extraction_error;\n"
                        "DELETE FROM documents_fts WHERE sha256 = " (sql-literal sha256) ";\n"
                        (when searchable?
                          (str "INSERT INTO documents_fts (sha256, basename, content) VALUES ("
                               (str/join ", " [(sql-literal sha256)
                                                (sql-literal basename)
                                                (sql-literal content)])
                               ");\n"))
                        "COMMIT;")))))

(defn search
  ([db-path query] (search db-path query 20))
  ([db-path query limit]
   (ensure-schema! db-path)
   (query! db-path
           (str "SELECT d.sha256,\n"
                "       d.archive_name,\n"
                "       d.archive_path,\n"
                "       d.basename,\n"
                "       d.mime_type,\n"
                "       d.extractor,\n"
                "       d.indexed_at,\n"
                "       d.content_chars,\n"
                "       d.extraction_status,\n"
                "       snippet(documents_fts, 2, '[', ']', ' … ', 12) AS snippet,\n"
                "       bm25(documents_fts) AS rank\n"
                "  FROM documents_fts\n"
                "  JOIN documents d USING (sha256)\n"
                " WHERE documents_fts MATCH " (sql-literal query) "\n"
                " ORDER BY rank, d.indexed_at DESC\n"
                " LIMIT " (max 0 (long limit)) ";"))))

(defn document-by-sha256 [db-path sha256]
  (ensure-schema! db-path)
  (first
   (query! db-path
           (str "SELECT sha256,\n"
                "       archive_name,\n"
                "       archive_path,\n"
                "       basename,\n"
                "       mime_type,\n"
                "       extractor,\n"
                "       indexed_at,\n"
                "       content_chars,\n"
                "       extraction_status,\n"
                "       extraction_error\n"
                "  FROM documents\n"
                " WHERE sha256 = " (sql-literal sha256) ";"))))
