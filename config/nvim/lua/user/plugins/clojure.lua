-- luacheck: ignore vim
local sexp_filetypes = {
  'clojure',
  'scheme',
  'lisp',
  'racket',
  'hy',
  'fennel',
  'janet',
  'carp',
  'wast',
  'yuck',
}
return {
  -- Syntax
  --{
  --  'nvim-treesitter/nvim-treesitter',
  --  opts = function(_, opts)
  --    if type(opts.ensure_installed) == 'table' then
  --      vim.list_extend(opts.ensure_installed, { 'clojure' })
  --    end
  --  end,
  --},
  {
    'clojure-vim/clojure.vim',
    ft = 'clojure',
    init = function()
      -- Attempt to follow cljfmt defaults
      vim.g['clojure_align_subforms'] = 1
      vim.g['clojure_fuzzy_indent_patterns'] = {
        '^case$',
        '^comment$',
        '^cond$',
        '^def',
        '^do',
        '^future$',
        '^tests',
        '^thread$',
        '^try$',
        '^with',
      }
    end,
  },
  {
    'luochen1990/rainbow',
    ft = sexp_filetypes,
    init = function()
      vim.g['rainbow_active'] = 1
    end,
  },

  -- TODO add cmp-conjure

  -- Editing
  {
    'gpanders/nvim-parinfer',
    ft = sexp_filetypes,
    config = function()
      vim.g['parinfer_enabled'] = false

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup(
          'MyParinferMappings',
          { clear = true }
        ),
        callback = function()
          vim.api.nvim_buf_set_keymap(
            0,
            'n',
            '<localleader>pt',
            '<cmd>ParinferToggle<cr>',
            {}
          )
          vim.api.nvim_buf_set_keymap(
            0,
            'n',
            '<localleader>pe',
            '<cmd>ParinferOn<cr>',
            {}
          )
          vim.api.nvim_buf_set_keymap(
            0,
            'n',
            '<localleader>pd',
            '<cmd>ParinferOff<cr>',
            {}
          )
        end,
        pattern = 'clojure',
      })
    end,
  },
  { 'guns/vim-sexp', ft = sexp_filetypes },
  { 'tpope/vim-sexp-mappings-for-regular-people', ft = sexp_filetypes },

  -- Runtime and REPL
  { 'tpope/vim-classpath', lazy = true, ft = { 'java', 'clojure' } },
  {
    'Olical/conjure',
    ft = { 'clojure', 'fennel' },
    init = function()
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#cmd'] =
        'conjure-auto-repl $port'
      vim.g['conjure#client#clojure#nrepl#refresh#before'] = 'user/stop'
      vim.g['conjure#client#clojure#nrepl#refresh#after'] = 'user/start'
      vim.g['conjure#log#botright'] = true
      vim.g['conjure#mapping#doc_word'] = 'gk'

      -- Disable LSP diagnostics in Conjure log buffers
      vim.api.nvim_create_autocmd('BufNewFile', {
        callback = function(_ev)
          vim.diagnostic.disable(0)
        end,
        group = vim.api.nvim_create_augroup(
          'MyConjureLogDisableLSP',
          { clear = true }
        ),
        pattern = 'conjure-log-*',
      })

      -- Use Lisp style line comments
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(_ev)
          vim.bo.commentstring = ';; %s'
        end,
        group = vim.api.nvim_create_augroup(
          'MyClojureCommentConfig',
          { clear = true }
        ),
        pattern = 'clojure',
      })
    end,
  },
}
