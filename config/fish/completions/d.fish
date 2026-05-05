function __d_complete_tasks
    if test -f "$HOME/.user.justfile"
        just --summary --justfile "$HOME/.user.justfile" 2>/dev/null | string split " "
    end
end

complete -f -c d -a "(__d_complete_tasks)"
