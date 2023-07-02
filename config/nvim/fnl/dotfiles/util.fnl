(module dotfiles.util
  {autoload {nvim aniseed.nvim
             a aniseed.core}})

(defn expand [path]
  (nvim.fn.expand path))

(defn glob [path]
  (nvim.fn.glob path true true true))

(defn exists? [path]
  (= (nvim.fn.filereadable path) 1))

(defn lua-file [path]
  (nvim.ex.luafile path))

(def config-path (nvim.fn.stdpath "config"))

;; TODO refactor and consolidate mapping functions (use vim.keymap.set)
(defn noremap [modes from to opts]
  (let [map-opts {:noremap true
                  :silent true}
        to (.. ":" to "<cr>")]
    (each [_ mode (ipairs modes)]
      (if (a.get opts :local?)
        (nvim.buf_set_keymap 0 mode from to map-opts)
        (nvim.set_keymap mode from to map-opts)))))

(defn nnoremap [from to opts]
  (noremap [:n] from to opts))

(defn lnnoremap [from to]
  (nnoremap (.. "<leader>" from) to))
