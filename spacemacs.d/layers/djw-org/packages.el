(setq djw-org-packages '())

(defun org/post-init-org ()
  (use-package org
    :commands (evil-org-mode evil-org-recompute-clocks)
    :init (add-hook 'org-mode-hook 'evil-org-mode)
    :config
    (progn
      (setq org-brain-path "~/Org/brain"))))
