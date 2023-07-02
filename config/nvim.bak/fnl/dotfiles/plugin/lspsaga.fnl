(module dotfiles.plugin.lspsaga
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(let [(ok? saga) (pcall require :lspsaga)]
  (when ok?
    (saga.setup
      {:lightbulb
       {:enable false}
       :symbol_in_winbar
       {:enable false}})

    (map :K  "Lspsaga hover_doc")
    (map :gh "Lspsaga lsp_finder")
    (map :gp "Lspsaga peek_definition")
    (map :<leader>lr "Lspsaga rename")
    ;; TODO do this in visual mode too
    (map :<leader>la "Lspsaga code_action")
    (map :<leader>lo "LSoutlineToggle")))
