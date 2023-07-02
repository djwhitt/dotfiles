(module dotfiles.filetypes
  {autoload {nvim aniseed.nvim}})

;; Filetype specific settings
(nvim.ex.autocmd :FileType "go" "setlocal nolist")
(nvim.ex.autocmd :FileType "erlang" "setlocal nolist")
