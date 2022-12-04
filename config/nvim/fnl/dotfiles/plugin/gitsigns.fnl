(module dotfiles.plugin.gitsigns
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? gitsigns) (pcall require :gitsigns)]
  (when ok?
    (gitsigns.setup)))
