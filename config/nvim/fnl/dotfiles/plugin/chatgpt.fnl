;; Add comments describing each line of code
(module dotfiles.plugin.chatgpt
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? chatgpt) (pcall require :chatgpt)]
  (when ok?
    (chatgpt.setup
      {:actions_paths
       ["~/.config/nvim/actions.json"]})))
