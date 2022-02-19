(module dotfiles.core
  {autoload {nvim aniseed.nvim}})

;; Generic Neovim configuration
(set nvim.o.termguicolors true)
(set nvim.o.mouse "a")
(set nvim.o.updatetime 500)
(set nvim.o.timeoutlen 500)
(set nvim.o.sessionoptions "blank,curdir,folds,help,tabpages,winsize")
(set nvim.o.inccommand :split)

;; Indentation
(set nvim.o.tabstop 2)
(set nvim.o.softtabstop 2)
(set nvim.o.shiftwidth 2)
(set nvim.o.expandtab true)

;(nvim.ex.set :spell)
(nvim.ex.set :list)
