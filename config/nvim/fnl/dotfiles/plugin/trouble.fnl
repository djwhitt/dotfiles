(module dotfiles.plugin.trouble
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? trouble) (pcall require :trouble)]
  (when ok?
    (trouble.setup)))
