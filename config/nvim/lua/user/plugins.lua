return {
  {
    "airblade/vim-rooter",
    event = "VeryLazy",
    init = function() 
      vim.g.rooter_silent_chdir = 1
    end,
  },
  {
    "andythigpen/nvim-coverage",
    lazy = false,
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("coverage").setup()
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
    "github/copilot.vim",
    event = "VeryLazy",
  },
  {
    "direnv/direnv.vim",
    lazy = false,
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
    "tpope/vim-dispatch",
    lazy = false,
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "tpope/vim-projectionist",
    lazy = false,
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require("astronvim.utils.status")
      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info { filename = {}, file_modified = false },
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode { surround = { separator = "right" } },
      }

      return opts
    end,
  },
}
