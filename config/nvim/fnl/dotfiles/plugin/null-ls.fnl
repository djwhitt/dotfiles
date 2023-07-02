(module dotfiles.plugin.null-ls
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(let [(ok? null-ls) (pcall require :null-ls)]
  (when ok?
    (null-ls.setup
      {:sources
       [null-ls.builtins.code_actions.eslint_d
        null-ls.builtins.code_actions.gitsigns
        null-ls.builtins.diagnostics.eslint_d
        null-ls.builtins.diagnostics.flake8
        null-ls.builtins.formatting.isort
        null-ls.builtins.formatting.prettier
        null-ls.builtins.formatting.yapf]})))
