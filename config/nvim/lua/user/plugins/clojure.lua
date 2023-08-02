
return {
  {
    "Olical/conjure",
    lazy = false,
    init = function()
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#cmd'] = "conjure-auto-repl"
      vim.g['conjure#client#clojure#nrepl#refresh#before'] = 'user/stop'
      vim.g['conjure#client#clojure#nrepl#refresh#after'] = 'user/start'

      -- Disable LSP diagnostics in Conjure log buffers
      vim.api.nvim_create_autocmd('BufNewFile', {
        callback = function(ev)
          vim.diagnostic.disable(0)
        end,
        group = vim.api.nvim_create_augroup('MyConjureLogDisableLSP', { clear = true }),
        pattern = 'conjure-log-*',
      })

      -- Use Lisp style line comments
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          vim.bo.commentstring = ";; %s"
        end,
        group = vim.api.nvim_create_augroup('MyClojureCommentConfig', { clear = true }),
        pattern = 'clojure',
      })
    end,
  },
}
