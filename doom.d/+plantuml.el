;;; -*- lexical-binding: t -*-

(after! plantuml-mode

  (let* ((config (concat (getenv "HOME")  "/.doom.d/+plantuml/config.cfg"))
         (executable (locate-file "plantuml" exec-path))
         (jar (thread-first executable
                (file-truename)
                (file-name-directory)
                (concat "../lib/plantuml.jar")
                (file-truename))))
    (setq flycheck-plantuml-executable executable
          org-plantuml-jar-path jar
          plantuml-executable-args (list "-headless" "-config" config)
          plantuml-executable-path executable
          plantuml-jar-path jar
          plantuml-output-type "png"))

  )
