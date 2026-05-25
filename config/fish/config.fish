set -g fish_greeting ""

alias j="just"

if command ls --version 2>/dev/null | string match -q "*GNU*"
    alias ls "ls --hyperlink=auto --color=auto"
else
    alias ls "ls -G"
end

if type -q mise
    mise activate fish | source
end

if status is-interactive
    if type -q atuin
        atuin init fish | source
    end
end

# opencode
fish_add_path $HOME/.opencode/bin
