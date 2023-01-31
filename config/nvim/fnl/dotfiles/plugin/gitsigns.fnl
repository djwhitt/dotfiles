(module dotfiles.plugin.gitsigns
  {autoload {a aniseed.core
             nvim aniseed.nvim
             util dotfiles.util}})

(defn- on-attach [bufnr]
  (let [map (fn [modes from to opts]
              (let [map-opts (if (a.get opts :expr?)
                               {:noremap true
                                :silent true
                                :expr true}
                               {:noremap true
                                :silent true})]
                (each [_ mode (ipairs modes)]
                  (nvim.buf_set_keymap bufnr mode from to map-opts))))]

    ;; Navigation
    (map [:n] "]c" "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'" {:expr? true})
    (map [:n] "[c" "&diff ? ']c' : '<cmd>Gitsigns prev_hunk<CR>'" {:expr? true})

    ;; Actions
    (map [:n :v] :<leader>hs ":Gitsigns stage_hunk<CR>")
    (map [:n :v] :<leader>hr ":Gitsigns reset_hunk<CR>")
    (map [:n] :<leader>hS ":Gitsigns stage_buffer<CR>")
    (map [:n] :<leader>hu ":Gitsigns undo_stage_hunk<CR>")
    (map [:n] :<leader>hR ":Gitsigns reset_buffer<CR>")
    (map [:n] :<leader>hp ":Gitsigns preview_hunk<CR>")
    (map [:n] :<leader>hb ":lua require('gitsigns').blame_line{full=true}<CR>")
    (map [:n] :<leader>tb ":Gitsigns toggle_current_line_blame<CR>")
    (map [:n] :<leader>hd ":Gitsigns diffthis<CR>")
    (map [:n] :<leader>hD ":lua require('gitsigns').diffthis('~')<CR>")
    (map [:n] :<leader>td ":Gitsigns toggle_deleted<CR>")

    ;; Text objects
    (map [:o :x] :ih "<C-U>Gitsigns select_hunk<CR>")))

(let [(ok? gitsigns) (pcall require :gitsigns)]
  (when ok?
    (gitsigns.setup
      {:on_attach on-attach})))
