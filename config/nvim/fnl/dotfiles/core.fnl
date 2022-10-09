(module dotfiles.core
  {autoload {nvim aniseed.nvim}})

;; Generic Neovim configuration
(set nvim.o.termguicolors true)
(set nvim.o.mouse "a")
(set nvim.o.updatetime 500)
(set nvim.o.timeoutlen 500)
(set nvim.o.sessionoptions "blank,curdir,folds,help,tabpages,winsize")
(set nvim.o.inccommand :split)
(set nvim.o.shada "!,'1000,<50,s10,h") ;; 1000 oldfiles

;(nvim.ex.set :spell)
(nvim.ex.set :list)
