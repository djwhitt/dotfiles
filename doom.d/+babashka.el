(after! prodigy

  (prodigy-define-service
    :name "Babashka"
    :command "bb"
    :args '("--nrepl-server")
    :cwd "~/"
    :tags '(personal)
    :stop-signal 'sigint
    :kill-process-buffer-on-stop t)

  )
