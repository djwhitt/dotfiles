return {
  options = {
    opt = {
      cmdheight = 1,
      foldcolumn = "0",
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
        -- Use null-ls only for typescript
        if vim.bo.filetype == "typescript" then
          return client.name == "null-ls"
        end

        return true
      end 
    },
    servers = {
      "clojure_lsp",
      "tsserver"
    },
  },
  mappings = {
    n = {
      ["<leader><leader>"] = {
        "<cmd>ChatGPT<cr>",
        desc = "ChatGPT",
      },
      ["<leader>gg"] = {
        "<cmd>G<cr>",
        desc = "Vim fugitive G",
      },
      ["<leader><tab>"] = {
        "<cmd>A<cr>",
        desc = "Switch to alternate file as defined by vim-projectionist",
      },
      ["<localleader>ts"] = {
        "<cmd>TestSuite<cr>",
        desc = "Run test suite using vim-test",
      }
    },
    v = {
      ["<leader><leader>"] = {
        "<cmd>ChatGPTRun follow_instructions<cr>",
        desc = "ChatGPT follow instructions",
      },
    },
  },
}
