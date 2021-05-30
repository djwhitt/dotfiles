;;; -*- lexical-binding: t -*-

(after! plantuml-mode

  (let ((plantuml-config (concat (getenv "HOME")  "/.doom.d/+plantuml/config.cfg")))
    (setq plantuml-executable-args (list "-headless" "-config" plantuml-config)
          plantuml-output-type "png"))

  )
