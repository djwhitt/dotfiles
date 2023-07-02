return {
  {
    "airblade/vim-rooter",
    lazy = false,
    init = function() 
      vim.g.rooter_silent_chdir = 1
    end,
  },
  {
    "clojure-vim/clojure.vim",
    lazy = false,
    init = function()
      vim.g.clojure_align_subforms = 1
      vim.g.clojure_fuzzy_indent_patterns = {
        "^comment$", 
        "^def", 
        "^do", 
        "^future$", 
        "^let", 
        "^tests", 
        "^with"
      }
    end,
  },
  {
    "github/copilot.vim",
    lazy = false,
  },
  {
    "guns/vim-sexp",
    lazy = false,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function (_, opts)
      local cmp = require "cmp"

      opts.mapping['<Tab>'] = cmp.config.disable
      opts.mapping['<S-Tab>'] = cmp.config.disable

      return opts
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },
  {
    "Olical/conjure",
    lazy = false,
    init = function()
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#cmd'] = "conjure-auto-repl"
    end,
  },
}
