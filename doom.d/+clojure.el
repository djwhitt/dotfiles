;;; -*- lexical-binding: t -*-

(add-to-list 'interpreter-mode-alist
             '("bb" . clojure-mode))

;; Based off of spacemac's https://github.com/syl20bnr/spacemacs/blob/develop/layers/+lang/clojure/funcs.el
;; commit: 3663b29a48d8a47c9920f9e9261f94630ca389d8
(after! cider

  (assoc-delete-all "^\\*cider-error*"  +popup--display-buffer-alist)
  (assoc-delete-all "^\\*cider-repl" +popup--display-buffer-alist)

  (set-popup-rule! "^\\*cider-error*" :quit t :modeline t)

  (setq cider-repl-pop-to-buffer-on-connect nil)

  )

(after! clojure-mode

  (define-clojure-indent
    (DELETE 2)
    (GET 2)
    (POST 2)
    (PUT 2)
    (assoc 0)
    (async nil)
    (at 1)
    (await 1)
    (case-of 2)
    (catch-pg-key-error 1)
    (context 2)
    (defplugin '(1 :form (1)))
    (element 2)
    (ex-info 0)
    (filter-routes 1)
    (fn-traced 1)
    (handle-pg-key-error 2)
    (js/React.createElement 2)
    (match 1)
    (promise 1)
    (prop/for-all 1)
    (s/fdef 1))

  )

;; Derived from https://github.com/plexus/corgi/blob/43832042f4e5dc77f38e3602c0f4e916544a6f44/corgi-user-config.arne.el

;;;###autoload
(defun babashka-scratch ()
  (interactive)
  (let* ((buf (get-buffer-create "*babashka-scratch*")))
    (with-current-buffer buf
      (clojure-mode)
      (babashka-jack-in
       (lambda (_)
         (sesman-link-session 'CIDER '("babashka") 'buffer buf))))
    (switch-to-buffer buf)))

;;;###autoload
(defun babashka-quit ()
  (interactive)
  (setq sesman-links-alist
        (a-dissoc sesman-links-alist '(CIDER . "babashka")))
  (when (get-buffer "*babashka-nrepl-server*")
    (kill-buffer "*babashka-nrepl-server*"))
  (when (get-buffer "*babashka-repl*")
    (kill-buffer "*babashka-repl*")))

;;;###autoload
(defun babashka-jack-in (&optional connected-callback)
  (interactive)
  (babashka-quit)
  (let* ((cmd "bb --nrepl-server 32985") ;; TODO switch to port 0 when Babasha 0.2.4 comes out
         (serv-buf (get-buffer-create "*babashka-nrepl-server*"))
         (host "127.0.0.1")
         (repl-builder (lambda (port)
                         (lambda (_)
                           (let ((repl-buf (get-buffer-create "*babashka-repl*")))
                             (with-current-buffer repl-buf
                               (cider-repl-create (list :repl-buffer repl-buf
                                                        :repl-type 'clj
                                                        :host host
                                                        :port port
                                                        :project-dir "~"
                                                        :session-name "babashka"
                                                        :repl-init-function (lambda ()
                                                                              (setq-local cljr-suppress-no-project-warning t
                                                                                          cljr-suppress-middleware-warnings t)
                                                                              (rename-buffer "*babashka-repl*")))))))))
         (port-filter (lambda (serv-buf)
                        (lambda (process output)
                          (when (buffer-live-p serv-buf)
                            (with-current-buffer serv-buf
                              (insert output)
                              (when (string-match "Started nREPL server at 127.0.0.1:\\([0-9]+\\)" output)
                                (let ((port (string-to-number (match-string 1 output))))
                                  (setq nrepl-endpoint (list :host host :port port))
                                  (let ((client-proc (nrepl-start-client-process
                                                      host
                                                      port
                                                      process
                                                      (funcall repl-builder port))))
                                    (set-process-query-on-exit-flag client-proc nil)
                                    (when connected-callback
                                      (funcall connected-callback client-proc)))))))))))
    (with-current-buffer serv-buf
      (setq nrepl-is-server t
            nrepl-server-command cmd))
    (let ((serv-proc (start-file-process-shell-command "babashka-nrepl-server" serv-buf cmd)))
      (set-process-query-on-exit-flag serv-proc nil)
      (set-process-filter serv-proc (funcall port-filter serv-buf))
      (set-process-sentinel serv-proc 'nrepl-server-sentinel)
      (set-process-coding-system serv-proc 'utf-8-unix 'utf-8-unix)))
  nil)

;;;###autoload
(defun ++clojure/cider-find-var (sym-name &optional arg)
  "Attempts to jump-to-definition of the symbol-at-point. If CIDER fails, or not available, falls
back to dumb-jump."
  (interactive (list (cider-symbol-at-point)))
  (if (and (cider-connected-p) (cider-var-info sym-name))
      (unless (eq 'symbol (type-of (cider-find-var nil sym-name)))
        (dumb-jump-go))
    (dumb-jump-go)))

;;;###autoload
(defun ++clojure/cider-display-error-buffer (&optional arg)
  "Displays the *cider-error* buffer in the current window. If called with a prefix argument, uses
the other-window instead."
  (interactive "P")
  (let ((buffer (get-buffer cider-error-buffer)))
    (when buffer
      (funcall (if (equal arg '(4))
                   'switch-to-buffer-other-window
                 'switch-to-buffer)
               buffer))))

;;;###autoload
(defun ++clojure/cider-eval-sexp-beginning-of-line ()
  "Evaluate the last sexp at the beginning of the current line."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (cider-eval-last-sexp)))

;;;###autoload
(defun ++clojure/cider-eval-sexp-end-of-line ()
  "Evaluate the last sexp at the end of the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (cider-eval-last-sexp)))

;;;###autoload
(defun ++clojure/cider-eval-in-repl-no-focus (form)
  "Insert FORM in the REPL buffer and eval it."
  (while (string-match "\\`[ \t\n\r]+\\|[ \t\n\r]+\\'" form)
    (setq form (replace-match "" t t form)))
  (with-current-buffer (cider-current-connection)
    (let ((pt-max (point-max)))
      (goto-char pt-max)
      (insert form)
      (indent-region pt-max (point))
      (cider-repl-return)
      (with-selected-window (get-buffer-window (cider-current-connection))
        (goto-char (point-max))))))

;;;###autoload
(defun ++clojure/cider-send-last-sexp-to-repl ()
  "Send last sexp to REPL and evaluate it without changing the focus."
  (interactive)
  (++clojure//cider-eval-in-repl-no-focus (cider-last-sexp)))

;;;###autoload
(defun ++clojure/cider-send-last-sexp-to-repl-focus ()
  "Send last sexp to REPL and evaluate it and switch to the REPL in `insert state'."
  (interactive)
  (cider-insert-last-sexp-in-repl t)
  (evil-insert-state))

;;;###autoload
(defun ++clojure/cider-send-region-to-repl (start end)
  "Send region to REPL and evaluate it without changing the focus."
  (interactive "r")
  (++clojure//cider-eval-in-repl-no-focus
   (buffer-substring-no-properties start end)))

;;;###autoload
(defun ++clojure/cider-send-region-to-repl-focus (start end)
  "Send region to REPL and evaluate it and switch to the REPL in `insert state'."
  (interactive "r")
  (cider-insert-in-repl
   (buffer-substring-no-properties start end) t)
  (evil-insert-state))

;;;###autoload
(defun ++clojure/cider-send-function-to-repl ()
  "Send current function to REPL and evaluate it without changing the focus."
  (interactive)
  (++clojure//cider-eval-in-repl-no-focus (cider-defun-at-point)))

;;;###autoload
(defun ++clojure/cider-send-function-to-repl-focus ()
  "Send current function to REPL and evaluate it and switch to the REPL in `insert state'."
  (interactive)
  (cider-insert-defun-in-repl t)
  (evil-insert-state))

;;;###autoload
(defun ++clojure/cider-send-ns-form-to-repl-focus ()
  "Send ns form to REPL and evaluate it and switch to the REPL in `insert state'."
  (interactive)
  (cider-insert-ns-form-in-repl t)
  (evil-insert-state))

;;;###autoload
(defun ++clojure/cider-find-and-clear-repl-buffer ()
  "Calls cider-find-and-clear-repl-output interactively with C-u prefix set so that it clears the
whole REPL buffer, not just the output."
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively 'cider-find-and-clear-repl-output)))

;; Keybindings
;; Based off of spacemac's https://github.com/syl20bnr/spacemacs/blob/develop/layers/+lang/clojure/packages.el
;; commit: ba982822c6b4b9e784d5c1fa35afa3e5126b4593
(after! (cider clj-refactor)
  ;; Unbind
  (map!
   :localleader
   (:map clojure-mode-map
    "R" nil)
   (:map cider-repl-mode-map
    "," nil "c" nil "n" nil "q" nil "r" nil)
   (:map (clojure-mode-map clojurescript-mode-map)
    "'" nil "\"" nil "c" nil "C" nil "i" nil "e" nil "g" nil
    "h" nil "m" nil "M" nil "n" nil "r" nil "t" nil))

  (map!
   :localleader
   (:map cider-repl-mode-map
    :desc "Switch to code"                         ","       #'cider-switch-to-last-clojure-buffer)
   (:map (clojure-mode-map clojurescript-mode-map)
    :desc "Switch to repl"                         ","       #'cider-switch-to-repl-buffer)
   (:map (clojure-mode-map clojurescript-mode-map cider-repl-mode-map)
    :desc "Start repl"                             "'"       #'sesman-start
    (:prefix ("d"  . "debug")
     :desc "Debug defun at point"                  "b"       #'cider-debug-defun-at-point
     :desc "Display cider errors"                  "e"       #'++clojure/cider-display-error-buffer
     :desc "Cider inspect"                         "i"       #'cider-inspect
     :desc "Cider inspect last result"             "r"       #'cider-inspect-last-result)
    (:prefix ("e"  . "evaluation")
     :desc "Eval sexp at beginning of line"        "^"       #'++clojure/cider-eval-sexp-beginning-of-line
     :desc "Eval sexp at end of line"              "$"       #'++clojure/cider-eval-sexp-end-of-line
     :desc "Eval defun to comment"                 ";"       #'cider-eval-defun-to-comment
     :desc "Eval buffer"                           "b"       #'cider-eval-buffer
     :desc "Eval last sexp"                        "e"       #'cider-eval-last-sexp
     :desc "Eval defun at point"                   "f"       #'cider-eval-defun-at-point
     :desc "Eval interupt"                         "i"       #'cider-interrupt
     :desc "Eval macroexpand"                      "m"       #'cider-macroexpand-1
     :desc "Eval macroexpand-all"                  "M"       #'cider-macroexpand-all
     :desc "Eval region"                           "r"       #'cider-eval-region
     :desc "Undef"                                 "u"       #'cider-undef
     :desc "Eval sexp at point"                    "v"       #'cider-eval-sexp-at-point
     :desc "Eval sexp up to point"                 "V"       #'cider-eval-sexp-up-to-point
     :desc "Eval last sexp and replace"            "w"       #'cider-eval-last-sexp-and-replace
     (:prefix ("n" . "namespace")
      :desc "Namespace refresh"                    "n"       #'cider-ns-refresh
      :desc "Namespace reload"                     "r"       #'cider-ns-reload
      :desc "Namespace reload all"                 "R"       #'cider-ns-reload-all)
     (:prefix ("p" . "pprint")
      :desc "Eval pprint defun to comment"         ";"       #'cider-pprint-eval-defun-to-comment
      :desc "Eval pprint last sexp to comment"     ":"       #'cider-pprint-eval-last-sexp-to-comment
      :desc "Eval pprint defun at point"           "f"       #'cider-pprint-eval-defun-at-point
      :desc "Eval pprint last sexp"                "e"       #'cider-pprint-eval-last-sexp))
    (:prefix ("f"  . "format")
     :desc "Format buffer"                         "="       #'cider-format-buffer
     :desc "Format defun"                          "f"       #'cider-format-defun
     :desc "Format region"                         "r"       #'cider-format-region
     (:prefix ("e" . "edn")
      :desc "Format edn buffer"                    "b"       #'cider-format-edn-buffer
      :desc "Format edn last sexp"                 "e"       #'cider-format-edn-last-sexp
      :desc "Format edn region"                    "r"       #'cider-format-edn-region))
    (:prefix ("g"  . "goto")
     :desc "Pop back"                              "b"       #'cider-pop-back
     :desc "Classpath"                             "c"       #'cider-classpath
     :desc "Find var"                              "g"       #'++clojure/cider-find-var
     :desc "Jump to compilation error"             "e"       #'cider-jump-to-compilation-error
     :desc "Find namespace"                        "n"       #'cider-find-ns
     :desc "Find resource"                         "r"       #'cider-find-resource
     :desc "Browse spec"                           "s"       #'cider-browse-spec
     :desc "Browse all specs"                      "S"       #'cider-browse-spec-all)
    (:prefix ("h"  . "help")
     :desc "Apropos"                               "a"       #'cider-apropos
     :desc "Cheatsheet"                            "c"       #'cider-cheatsheet
     :desc "Clojuredocs"                           "d"       #'cider-clojuredocs
     :desc "Doc"                                   "h"       #'cider-doc
     :desc "Javadoc"                               "j"       #'cider-javadoc
     :desc "Browse namespace"                      "n"       #'cider-browse-ns
     :desc "Browse all namespaces"                 "N"       #'cider-browse-ns-all
     :desc "Browse spec"                           "s"       #'cider-browse-spec
     :desc "Browse all specs"                      "S"       #'cider-browse-spec-all)
    (:prefix ("m"  . "manage repls")
     :desc "Sesman start"                          "'"       #'sesman-start
     :desc "Sesman browser"                        "b"       #'sesman-browser
     :desc "Sesman info"                           "i"       #'sesman-info
     :desc "Sesman goto"                           "g"       #'sesman-goto
     :desc "Sesman quit"                           "q"       #'sesman-quit
     :desc "Sesman restart"                        "r"       #'sesman-restart
     (:prefix ("c" . "cider connect")
      :desc "Cider connect clj"                    "j"       #'cider-connect-clj
      :desc "Cider connect sibling clj"            "J"       #'cider-connect-sibling-clj
      :desc "Cider connect clj&cljs"               "m"       #'cider-connect-clj&cljs
      :desc "Cider connect cljs"                   "s"       #'cider-connect-cljs
      :desc "Cider connect sibling cljs"           "S"       #'cider-connect-sibling-cljs)
     (:prefix ("j" . "cider jack-in")
      :desc "Cider jack-in clj"                    "j"       #'cider-jack-in-clj
      :desc "Cider jack-in clj&cljs"               "m"       #'cider-jack-in-clj&cljs
      :desc "Cider jack-in cljs"                   "s"       #'cider-jack-in-cljs)
     (:prefix ("l" . "link")
      :desc "Sesman link with buffer"              "b"       #'sesman-link-with-buffer
      :desc "Sesman link with directory"           "d"       #'sesman-link-with-directory
      :desc "Sesman unlink"                        "u"       #'sesman-unlink
      :desc "Sesman link with project"             "p"       #'sesman-link-with-project)
     (:prefix ("s" . "cider session")
      :desc "Cider quit"                           "q"       #'cider-quit
      :desc "Cider restart"                        "r"       #'cider-restart))
    (:prefix ("p"  . "profile")
     :desc "Profile samples"                       "+"       #'cider-profile-samples
     :desc "Profile clear"                         "c"       #'cider-profile-clear
     :desc "Toggle profile namespace"              "n"       #'cider-profile-ns-toggle
     :desc "Profile var summary"                   "s"       #'cider-profile-var-summary
     :desc "Profile summary"                       "S"       #'cider-profile-summary
     :desc "Profile toggle"                        "t"       #'cider-profile-toggle
     :desc "Profile var profiled p"                "v"       #'cider-profile-var-profiled-p)
    (:prefix ("r" . "refactor")
     :desc "Toggle keyword-string"                 ":"       #'clojure-toggle-keyword-string
     :desc "Profile samples"                       "+"       #'cider-profile-samples
     :desc "Align"                                 "="       #'clojure-align
     :desc "Insert namespace form"                 "n"       #'clojure-insert-ns-form
     :desc "Insert namespace form at point"        "N"       #'clojure-insert-ns-form-at-point
     :desc "Cycle if"                              "i"       #'clojure-cycle-if
     :desc "Cycle privacy"                         "p"       #'clojure-cycle-privacy
     :desc "Sort namespace"                        "s"       #'clojure-sort-ns
     :desc "Unwind"                                "U"       #'clojure-unwind
     :desc "Unwind all"                            "U"       #'clojure-unwind-all
     (:prefix ("c" . "convert collection")
      :desc "Convert to set"                       "#"       #'clojure-convert-collection-to-set
      :desc "Convert to quoted list"               "'"       #'clojure-convert-collection-to-quoted-list
      :desc "Convert to list"                      "("       #'clojure-convert-collection-to-list
      :desc "Convert to vector"                    "["       #'clojure-convert-collection-to-vector
      :desc "Convert to map"                       "{"       #'clojure-convert-collection-to-map)
     (:prefix ("t" . "Thread")
      :desc "Thread first"                         "f"       #'clojure-thread-first-all
      :desc "Thread last"                          "l"       #'clojure-thread-last-all
      :desc "Thread"                               "t"       #'clojure-thread))
    (:prefix ("s"  . "send to repl")
     :desc "Load buffer"                           "b"       #'cider-load-buffer
     :desc "Load buffer and switch to repl"        "B"       #'cider-load-buffer-and-switch-to-repl-buffer
     :desc "Send last sexp"                        "e"       #'++clojure/cider-send-last-sexp-to-repl
     :desc "Send last sexp and switch to repl"     "E"       #'++clojure/cider-send-last-sexp-to-repl-focus
     :desc "Send function"                         "f"       #'++clojure/cider-send-function-to-repl
     :desc "Send function and switch to repl"      "F"       #'++clojure/cider-send-function-to-repl-focus
     :desc "Clear repl"                            "l"       #'cider-find-and-clear-repl-output
     :desc "Clear whole repl"                      "L"       #'++clojure/cider-find-and-clear-repl-buffer
     :desc "Set namespace"                         "n"       #'cider-repl-set-ns
     :desc "Send namespace and switch to repl"     "N"       #'++clojure/cider-send-ns-form-to-repl-focus
     :desc "Switch repls"                          "o"       #'cider-repl-switch-to-other
     :desc "Send region"                           "r"       #'++clojure/cider-send-region-to-repl
     :desc "Send region and switch to repl"        "R"       #'++clojure/cider-send-region-to-repl-focus
     :desc "Switch namespace and switch to repl"   "s"       #'+clojure/cider-switch-to-repl-buffer-and-switch-ns
     :desc "Require repl utils"                    "u"       #'cider-repl-require-repl-utils)
    (:prefix ("t"  . "test")
     :desc "Rerun test"                            "a"       #'cider-test-rerun-test
     :desc "Show report"                           "b"       #'cider-test-show-report
     :desc "Run loaded tests"                      "l"       #'cider-test-run-loaded-tests
     :desc "Run namespace tests"                   "n"       #'cider-test-run-ns-tests
     :desc "Run project tests"                     "p"       #'cider-test-run-project-tests
     :desc "Rerun failed tests"                    "r"       #'cider-test-rerun-failed-tests
     :desc "Run namespace tests with filters"      "s"       #'cider-test-run-ns-tests-with-filters
     :desc "Run test"                              "t"       #'cider-test-run-test))))
