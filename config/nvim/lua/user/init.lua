-- luacheck: ignore vim
return {
  options = {
    opt = {
      cmdheight = 1,
      foldcolumn = '0',
      number = false,
      relativenumber = false,
      shada = "!,'1000,<50,s10,h",
      showtabline = 0,
      splitbelow = false,
    },
  },
  lsp = {
    formatting = {
      format_on_save = false,
      filter = function(client)
        -- Use only efm for typescript
        if vim.bo.filetype == 'typescript' then
          return client.name == 'efm'
        end

        return true
      end,
      timeout_ms = 5000,
    },
    config = {
      efm = function()
        local util = require('lspconfig.util')

        local eslint_d = require('efmls-configs.linters.eslint_d')
        local luacheck = require('efmls-configs.linters.luacheck')
        local nixfmt = require('efmls-configs.formatters.nixfmt')
        local prettier = require('efmls-configs.formatters.prettier')
        local shellcheck = require('efmls-configs.linters.shellcheck')
        local stylua = require('efmls-configs.formatters.stylua')

        return {
          cmd = { 'efm-langserver' },
          root_dir = util.find_git_ancestor,
          single_file_support = true,
          init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
          },
          settings = {
            rootMarkers = { '.git/' },
            languages = {
              bash = { shellcheck },
              sh = { shellcheck },

              javascript = { eslint_d, prettier },
              typescript = { eslint_d, prettier },

              lua = { luacheck, stylua },

              nix = { nixfmt },
            },
          },
        }
      end,
    },
    servers = {
      'clojure_lsp',
      'efm',
      'nil_ls',
      'terraformls',
      'tsserver',
    },
  },
  mappings = {
    n = {
      -- TODO better binding
      ['<leader><leader>'] = {
        '<cmd>Dispatch<cr>',
        desc = 'Dispatch',
      },
      ['<leader>gg'] = {
        '<cmd>G<cr>',
        desc = 'Vim fugitive G',
      },
      ['<leader><tab>'] = {
        '<cmd>A<cr>',
        desc = 'Switch to alternate file as defined by vim-projectionist',
      },
      -- TODO better binding
      ['<localleader>d'] = {
        '<cmd>Dispatch<cr>',
        desc = 'Runs the default Dispatch command',
      },
    },
    v = {
      -- TODO better binding
      ['<leader><leader>'] = {
        '<cmd>ChatGPTRun follow_instructions<cr>',
        desc = 'ChatGPT follow instructions',
      },
    },
  },
}
