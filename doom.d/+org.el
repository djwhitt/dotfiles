;;; +org.el -*- lexical-binding: t; -*-

(setq org-directory "~/Org/")

(after! org

  (defun transform-square-brackets-to-round-ones(string-to-transform)
    "Transforms [ into ( and ] into ), other chars left unchanged."
    (concat
     (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c))) string-to-transform)))

  (setq org-capture-templates `(("L" "Protocol Link" entry (file ,(concat org-directory "roam/inbox.org"))
                                 "* %?[[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n")
                                ("S" "Protocol Selection" entry (file ,(concat org-directory "roam/inbox.org"))
                                 "* %^{Title}\nSource: %u, [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")))


  )

(after! org-roam

  (setq org-roam-db-location (concat user-emacs-directory "/.org-roam.db"))

  )
