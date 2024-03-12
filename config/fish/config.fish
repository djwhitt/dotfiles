alias tl="tmuxp load"
alias ls="ls --hyperlink=auto --color=auto"

if status is-interactive
  atuin init fish | source
end
