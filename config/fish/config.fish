alias tl="tmuxp load"
alias j="just"

if command ls --version 2>/dev/null | string match -q "*GNU*"
    alias ls "ls --hyperlink=auto --color=auto"
else
    alias ls "ls -G"
end

# Quick editing shortcuts
alias ef="e ~/.config/fish/config.fish"
alias em="e ~/.map.edn"
alias et="e ~/.local/src/clj/djwhitt/tasks.clj"
alias ev="e ~/.config/nvim/lua/plugins/astrocore.lua"

if status is-interactive
    if type -q atuin
        atuin init fish | source
    end
end
