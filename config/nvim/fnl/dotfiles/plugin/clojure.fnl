(module dotfiles.plugin.clojure
  {autoload {nvim aniseed.nvim}})

;; Match cljfmt defaults
(set nvim.g.clojure_align_subforms 1)
(set nvim.g.clojure_fuzzy_indent_patterns
     ["^comment$" "^def" "^do" "^future$" "^let" "^with"])
