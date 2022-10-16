(module dotfiles.plugin.lspsaga
  {autoload {util dotfiles.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(let [(ok? saga) (pcall require :lspsaga)]
  (when ok?
    (saga.init_lsp_saga)

    ;;(map :<C-j> "Lspsaga diagnostic_jump_next")
    (map :K  "Lspsaga hover_doc")
    (map :gd "Lspsaga lsp_finder")
    ;; TODO need to map this in insert mode
    ;;(map :<C-k> "Lspsaga signature_help")
    (map :gp "Lspsaga peek_definition")
    (map :<leader>lr "Lspsaga rename")
    ;; TODO do this in visual mode too
    (map :<leader>la "Lspsaga code_action")
    ))
