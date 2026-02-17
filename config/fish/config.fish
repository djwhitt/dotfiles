set -gx BAT_THEME TwoDark

alias tl="tmuxp load"
alias ls="ls --hyperlink=auto --color=auto"
alias j="just"

# Quick editing shortcuts
alias ef="e ~/.config/fish/config.fish"
alias em="e ~/.map.edn"
alias et="e ~/.local/src/clj/djwhitt/tasks.clj"
alias ev="e ~/.config/nvim/lua/plugins/astrocore.lua"

if status is-interactive
  atuin init fish | source
end
