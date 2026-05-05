set -g fish_greeting ""

alias tl="tmuxp load"
alias j="just"

if command ls --version 2>/dev/null | string match -q "*GNU*"
    alias ls "ls --hyperlink=auto --color=auto"
else
    alias ls "ls -G"
end

if status is-interactive
    if type -q atuin
        atuin init fish | source
    end
end
