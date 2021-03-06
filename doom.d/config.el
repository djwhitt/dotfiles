;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "David Whittington"
      user-mail-address "djwhitt@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one
      doom-font "DejaVu Sans Mono 11")

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!

(setq confirm-kill-emacs nil            ; Don't prompt when closing Emacs
      display-line-numbers-type nil)    ; Disable line numbers

;; Set leader keys
(setq doom-leader-key "SPC"
      doom-leader-alt-key "M-SPC"
      doom-localleader-key ","
      doom-localleader-alt-key "M-,")

;; Don't flycheck Doom configs in ~/.dotfiles
(setq +emacs-lisp-disable-flycheck-in-dirs
      (list doom-emacs-dir doom-private-dir "~/.dotfiles/doom.d"))

;; Dired bindings

(setq dired-hide-details-hide-symlink-targets nil)

(add-hook 'dired-mode-hook #'dired-hide-details-mode)

(map! :n "-" 'dired-jump)

;; Spacemacs like buffer toggling

(map! :leader
      :desc "Switch to last buffer"
      "TAB" 'evil-switch-to-windows-last-buffer)

;; Prodigy

;; (map! :leader
;;       :desc "Prodigy"
;;       "o y" 'prodigy)

;; Lastpass

;; (after! lastpass
;;   (setq lastpass-user "djwhitt@gmail.com"
;;         lastpass-shell "/run/current-system/sw/bin/bash")
;;   ;; Enable lastpass custom auth-source
;;   (lastpass-auth-source-enable))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; PIM
(load! "+email.el")
(load! "+org.el")

;; Languages
(load! "+clojure.el")
(load! "+plantuml.el")
(load! "+prolog.el")

;; Org projects
(load! "+dotfiles.el")
