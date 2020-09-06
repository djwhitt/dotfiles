(defun djw/org-confirm-babel-evaluate (lang body)
  (not (or (string= "ditaa" lang)
           (string= "plantuml" lang)
           (string= "dot" lang))))
