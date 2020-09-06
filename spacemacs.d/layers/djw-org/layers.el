(configuration-layer/declare-layer
 '(org :variables
       org-enable-hugo-support t
       org-enable-reveal-js-support t
       org-want-todo-bindings t

       ;; Journal
       org-enable-org-journal-support t
       org-journal-dir "~/Org/journal/"

       ;; Archive
       org-archive-location "~/Org/archive.org::* Notes"
       org-archive-reversed-order t))

(configuration-layer/declare-layer
 '(deft :variables
    deft-directory "~/Org/deft/"
    deft-zetteldeft t))
