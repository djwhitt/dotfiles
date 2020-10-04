(after! org

  (unless (boundp 'org-publish-project-alist)
    (setq org-publish-project-alist '()))

  ;; TODO define org publish config in dotfiles repo and read from there

  (add-to-list 'org-publish-project-alist
               '("dotfiles-assets"
                 :base-directory "~/.dotfiles/images"
                 :base-extension "png\\|jpg\\|svg"
                 :publishing-directory "~/.dotfiles/docs/images/"
                 :publishing-function org-publish-attachment))

  (add-to-list 'org-publish-project-alist
               '("dotfiles-tangles"
                 :base-directory "~/.dotfiles"
                 :base-extension "org"
                 :publishing-directory "~/.dotfiles/docs/"
                 :publishing-function org-html-publish-to-html))

  (add-to-list 'org-publish-project-alist
               '("dotfiles-org"
                 :base-directory "~/.dotfiles"
                 :base-extension "org"
                 :publishing-directory "~/.dotfiles/"
                 :publishing-function org-babel-tangle-publish))

  (add-to-list 'org-publish-project-alist
               '("dotfiles"
                 :components ("dotfiles-assets"
                              "dotfiles-tangles"
                              "dotfiles-org")
                 ;; TODO run a function that updates and tests dotfiles
                 ;; TODO consider using BATS for testing: https://github.com/bats-core/bats-core (there is a Nix package)
                 ;; :completion-function
                 ))

  )
