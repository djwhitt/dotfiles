
return {
  {
    "Olical/conjure",
    lazy = false,
    init = function()
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#cmd'] = "conjure-auto-repl"

      -- Disable LSP diagnostics in log buffers
      vim.api.nvim_create_autocmd('BufNewFile', {
        callback = function(ev)
          vim.diagnostic.disable(0)
        end,
        desc = 'Conjure Log disable LSP diagnostics',
        group = vim.api.nvim_create_augroup('conjure_log_disable_lsp', { clear = true }),
        pattern = 'conjure-log-*',
      })

      -- Use Lisp style line comments
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          vim.bo.commentstring = ";; %s"
        end,
        desc = 'Lisp style line comments',
        group = vim.api.nvim_create_augroup('comment_config', { clear = true }),
        pattern = 'clojure',
      })
    end,
  },
}
