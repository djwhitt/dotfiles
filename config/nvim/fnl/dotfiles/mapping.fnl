(module dotfiles.mapping
  {autoload {nvim aniseed.nvim
             nu aniseed.nvim.util
             core aniseed.core}})

(defn- noremap [mode from to]
  "Sets a mapping with {:noremap true}."
  (nvim.set_keymap mode from to {:noremap true}))

;; Disable CTRL-Z in dedicated terminal
(when (= nvim.env.KITTY_NVIM "true")
  (noremap :n "<c-z>" "<nop>"))

;; Generic mapping configuration
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader ",")

;; Don't exit visual mode when indenting
(noremap :v :< :<gv)
(noremap :v :> :>gv)

;; jk escape sequences
(noremap :i :jk :<esc>)
(noremap :c :jk :<c-c>)
(noremap :t :jk :<c-\><c-n>)

;; Spacemacs style leader mappings
(noremap :n :<leader>wm ":tab sp<cr>")
(noremap :n :<leader>wc ":only<cr>")
(noremap :n :<leader>bd ":bdelete!<cr>")
;;(noremap :n :<leader>sw ":mksession! .quicksave.vim<cr>")
;;(noremap :n :<leader>sr ":source .quicksave.vim<cr>")
(noremap :n :<leader><tab> ":e#<cr>")

;; Tab management
(noremap :n :th ":tabfirst<cr>")
(noremap :n :tj ":tabnext<cr>")
(noremap :n :tk ":tabpre<cr>")
(noremap :n :tl ":tablast<cr>")
(noremap :n :tt ":tabedit<cr>")
(noremap :n :tm ":tabm<space>")
(noremap :n :td ":tabclose<space>")
(noremap :n :to ":tabonly<cr>")
(noremap :n :tn ":tabnew<cr>")
(for [i 1 9]
  (noremap :n (.. "<leader>" i)  (.. i "gt<cr>")))

;; Delete hidden buffers
(noremap :n :<leader>bo ":call DeleteHiddenBuffers()<cr>")

;; Correct to first spelling suggestion
(noremap :n :<leader>zz ":normal! 1z=<cr>")

;; Trim trialing whitespace
(noremap :n :<leader>bt ":%s/\\s\\+$//e<cr>")

;; ChatGPT
(noremap :n :<leader><leader> ":ChatGPT<cr>")
(noremap :v :<leader><leader> ":ChatGPTRun follow_instructions<cr>")

;; Voice input
(noremap :n :<leader>v ":r !vtt<cr>")
;(noremap :n :<leader>yv ":silent !vtt | xclip -i -selection clipboard<cr>")

;; Dispatch
(noremap :n :<leader>n ":Dispatch<cr>")

(nu.fn-bridge
  :DeleteHiddenBuffers
  :dotfiles.mapping :delete-hidden-buffers)

(defn delete-hidden-buffers []
  (let [visible-bufs (->> (nvim.fn.range 1 (nvim.fn.tabpagenr :$))
                          (core.map nvim.fn.tabpagebuflist)
                          (unpack)
                          (core.concat))]
    (->> (nvim.fn.range 1 (nvim.fn.bufnr :$))
         (core.filter
           (fn [bufnr]
             (and (nvim.fn.bufexists bufnr)
                  (= -1 (nvim.fn.index visible-bufs bufnr)))))
         (core.run!
           (fn [bufnr]
             (nvim.ex.bwipeout bufnr))))))
