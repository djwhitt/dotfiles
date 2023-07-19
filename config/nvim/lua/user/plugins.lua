return {
  {
    "airblade/vim-rooter",
    event = "VeryLazy",
    init = function() 
      vim.g.rooter_silent_chdir = 1
    end,
  },
  {
    "aymericbeaumet/vim-symlink",
    lazy = false,
    dependencies = {
      "moll/vim-bbye",
    },
  },
  {
    "clojure-vim/clojure.vim",
    event = "VeryLazy",
  },
  {
    "github/copilot.vim",
    event = "VeryLazy",
  },
  {
    "guns/vim-sexp",
    event = "VeryLazy",
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function (_, opts)
      local cmp = require "cmp"

      -- Avoid interfering with copilot
      opts.mapping['<Tab>'] = cmp.config.disable
      opts.mapping['<S-Tab>'] = cmp.config.disable

      return opts
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        actions_paths = {
          "~/.config/nvim/lua/user/actions.json"
        }
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "eslint_d",
        "prettierd",
      },
      config = function(_, opts)
        local mason_null_ls = require "mason-null-ls"
        local null_ls = require "null-ls"
        mason_null_ls.setup(opts)
        mason_null_ls.setup {
          eslint_d = function()
            null_ls.register(null_ls.builtins.diagnostics.eslint_d.with {
              extra_args = { "--cache" },
              filetypes = { "javascript", "typescript" },
            })
          end,
          prettierd = function()
            null_ls.register(null_ls.builtins.formatting.prettierd.with {
              extra_filetypes = { "json", "markdown" } 
            })
          end,
        }
      end,
    },
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
