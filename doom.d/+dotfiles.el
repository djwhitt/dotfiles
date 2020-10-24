(after! org

  (unless (boundp 'org-publish-project-alist)
    (setq org-publish-project-alist '()))

  ;; TODO define org publish config in dotfiles repo and read from there

  (defun djw/org-babel-tangle-publish (_ filename pub-dir)
    "Tangle FILENAME and do nothings with the output."
    (org-babel-tangle-file filename))

  (defun djw/dotfiles-publish-completion (_)
    (shell-command "rcup")
    ;; TODO run fixups
    ;; TODO update other hosts (?)
    ;; TODO consider using BATS for testing: https://github.com/bats-core/bats-core (there is a Nix package)
    )

  (add-to-list 'org-publish-project-alist
               '("dotfiles-assets"
                 :base-directory "~/.dotfiles/images"
                 :base-extension "png\\|jpg\\|svg"
                 :publishing-directory "~/.dotfiles/docs/images/"
                 :publishing-function org-publish-attachment))

  ;; Use org-publish as a tangle build tool without publishing output
  (add-to-list 'org-publish-project-alist
               '("dotfiles-tangles"
                 :base-directory "~/.dotfiles"
                 :base-extension "org"
                 :publishing-directory "~/.dotfiles/"
                 :publishing-function djw/org-babel-tangle-publish
                 :completion-function djw/dotfiles-publish-completion))

  (add-to-list 'org-publish-project-alist
               '("dotfiles-org"
                 :base-directory "~/.dotfiles"
                 :base-extension "org"
                 :publishing-directory "~/.dotfiles/docs/"
                 :publishing-function org-html-publish-to-html))

  (add-to-list 'org-publish-project-alist
               '("dotfiles"
                 :components ("dotfiles-assets"
                              "dotfiles-tangles"
                              "dotfiles-org")))

  )
