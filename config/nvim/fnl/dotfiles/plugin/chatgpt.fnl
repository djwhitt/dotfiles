(module dotfiles.plugin.chatgpt
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? chatgpt) (pcall require :chatgpt)]
  (when ok?
    (chatgpt.setup
      {:yank_register "\""})))
