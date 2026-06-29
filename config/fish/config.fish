set -g fish_greeting ""

alias j="just"
alias contagent="$HOME/Work/misc/contagent/contagent"
alias cpi="$HOME/Work/misc/contagent/contagent pi"

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

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true
