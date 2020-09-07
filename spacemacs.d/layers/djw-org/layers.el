(configuration-layer/declare-layer
 '(org :variables
       org-enable-hugo-support t
       org-enable-reveal-js-support t
       org-want-todo-bindings t

       ;; Archive
       org-archive-location "~/Org/archive.org::* Notes"
       org-archive-reversed-order t

       ;; Brain
       org-brain-path "~/Org/notes/"

       ;; Journal
       org-enable-org-journal-support t
       org-journal-dir "~/Org/journal/"))

(configuration-layer/declare-layer
 '(deft :variables
    deft-directory "~/Org/notes/"
    deft-zetteldeft t))
