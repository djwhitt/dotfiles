(module dotfiles.plugin.vim-test
  {autoload {nvim aniseed.nvim
             util dotfiles.util}})

;; 'v' for validate
(util.lnnoremap :vn ":TestNearest")
(util.lnnoremap :vf ":TestFile<cr>")
(util.lnnoremap :va ":TestSuite<cr>")
(util.lnnoremap :vv ":TestLast<cr>")
(util.nnoremap :gt ":TestVisit<cr>")
