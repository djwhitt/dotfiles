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

;; https://github.com/jamesnvc/lsp_server
;; (set lsp.configs "prolog_lsp"
;;      {:default_config
;;       {:filetypes ["prolog"]
;;        :cmd ["swipl"
;;              "-g" "use_module(library(lsp_server))"
;;              "-g" "lsp_server:main"
;;              "-t" "halt"
;;              "--" "--stdio"]
;;        :root_dir lsp.util.root_pattern("pack.pl")}
;;       :docs 
;;       {:description "Prolog language server"}}}})
;; (lsp.prolog_lsp.setup {})

(let [lsp (require :lspconfig)]
  (when lsp
    (lsp.pyright.setup {})
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

    ;; TODO make binding buffer local
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

;; TODO should this go in another file?
(let [null-ls (require :null-ls)]
  (null-ls.setup
    {:sources
     [null-ls.builtins.diagnostics.eslint
      null-ls.builtins.code_actions.eslint
      null-ls.builtins.formatting.prettier]}))
