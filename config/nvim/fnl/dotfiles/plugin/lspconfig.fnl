(module dotfiles.plugin.lspconfig
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(defn- on-attach [client bufnr]
  (if client.resolved_capabilities.document_formatting
    (nvim.ex.autocmd "BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")))

(let [lsp (require :lspconfig)]
  (when lsp
    (lsp.clojure_lsp.setup {})
    (lsp.tsserver.setup 
      {:on_attach
       (fn [client bufnr]
         (set client.resolved_capabilities.document_formatting false)
         (set client.resolved_capabilities.document_range_formatting false)

         (let [ts-utils (require :nvim-lsp-ts-utils)]
           (ts-utils.setup {})
           (ts-utils.setup client))

         (on-attach client bufnr))})

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
    ;;(map :gd "lua vim.lsp.buf.definition()")
    ;;(map :gD "lua vim.lsp.buf.declaration()")
    ;;(map :gr "lua vim.lsp.buf.references()")
    ;;(map :gi "lua vim.lsp.buf.implementation()")
    ;;(map :K "lua vim.lsp.buf.hover()")
    (map :<c-k> "lua vim.lsp.buf.signature_help()")
    (map :<c-n> "lua vim.diagnostic.goto_prev()")
    (map :<c-p> "lua vim.diagnostic.goto_next()")

    (map :<leader>lr "lua vim.lsp.buf.rename()")
    (map :<leader>lf "lua vim.lsp.buf.formatting()")))

(let [null-ls (require :null-ls)]
  (null-ls.setup
    {:sources
     [null-ls.builtins.diagnostics.eslint
      null-ls.builtins.code_actions.eslint
      null-ls.builtins.formatting.prettier]
     :on_attach on-attach}))
