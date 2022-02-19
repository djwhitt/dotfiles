(module dotfiles.filetypes
  {autoload {nvim aniseed.nvim}})

;; Filetype specific settings
(nvim.ex.autocmd :FileType "go" "setlocal noexpandtab nolist ts=4 sw=4 sts=4")
(nvim.ex.autocmd :FileType "erlang" "setlocal noexpandtab nolist ts=4 sw=4 sts=4")
