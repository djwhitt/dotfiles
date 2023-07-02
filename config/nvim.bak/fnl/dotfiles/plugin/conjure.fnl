(module dotfiles.plugin.conjure
  {autoload {nvim aniseed.nvim}})

(set nvim.g.conjure#client#clojure#nrepl#connection#auto_repl#cmd "conjure-auto-repl")
