(module dotfiles.plugin.leap
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? leap) (pcall require :leap)]
  (when ok?
    (leap.add_default_mappings)))
