(module dotfiles.plugin.copilot)

(set vim.g.copilot_filetypes {"TelescopePrompt" false})

;; TODO extract common mapping logic
(vim.keymap.set :n "<leader>cpe" ":Copilot enable<CR>")
(vim.keymap.set :n "<leader>cpd" ":Copilot disable<CR>")
(vim.keymap.set :n "<leader>cps" ":Copilot status<CR>")
