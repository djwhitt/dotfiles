(module dotfiles.plugin.lspconfig
  {autoload {a aniseed.core 
             nvim aniseed.nvim
             util dotfiles.util}})

(defn- map [mode from to]
  (vim.keymap.set mode from to))

(defn- nmap [from to]
  (map :n from to))

(defn- format-buffer []
  (vim.lsp.buf.format
    {:timeout_ms 2000
     :filter (fn [client]
               (not= client.name "tsserver"))}))

(def border-type "single")

(vim.diagnostic.config 
  {:float 
   {:style "minimal"
    :border border-type
    :source "always"
    :header ""}})

(let [lsp (require :lspconfig)]
  (when lsp
    (lsp.clojure_lsp.setup {})
    (lsp.terraformls.setup {})
    (lsp.tsserver.setup 
      {:on_attach
       (fn [client bufnr]
         (set client.server_capabilities.document_formatting false)
         (set client.server_capabilities.document_range_formatting false)
         (let [ts-utils (require :nvim-lsp-ts-utils)]
           (ts-utils.setup {})
           (ts-utils.setup client)))})

    ;; More visually pleasing border styles
    (tset vim.lsp.handlers "textDocument/hover"
          (vim.lsp.with
            vim.lsp.handlers.hover
            {:border border-type}))

    (tset vim.lsp.handlers "textDocument/signatureHelp"
          (vim.lsp.with
            vim.lsp.handlers.signature_help
            {:border border-type}))

    (let [windows (require :lspconfig.ui.windows)]
      (when windows
        (tset windows.default_options :border border-type)))

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
    (nmap :gd vim.lsp.buf.definition)
    (nmap :gD vim.lsp.buf.declaration)
    (nmap :gr ":Telescope lsp_references<CR>")
    (nmap :gi ":Telescope lsp_implementations<CR>")
    (nmap :K vim.lsp.buf.hover)
    (nmap :<c-k> vim.lsp.buf.signature_help)
    (nmap :<c-n> vim.diagnostic.goto_prev)
    (nmap :<c-p> vim.diagnostic.goto_next)
    (nmap :<leader>lr vim.lsp.buf.rename)
    (nmap :<leader>lf format-buffer)))

(let [null-ls (require :null-ls)]
  (null-ls.setup
    {:sources
     [null-ls.builtins.diagnostics.eslint
      null-ls.builtins.code_actions.eslint
      null-ls.builtins.formatting.prettier]}))
