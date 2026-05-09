for dir in /run/current-system/sw/bin /etc/profiles/per-user/$USER/bin /opt/homebrew/bin /opt/homebrew/sbin $HOME/.local/bin $HOME/.config/emacs/bin
    if test -d $dir; and not contains $dir $PATH
        fish_add_path --prepend --global $dir
    end
end
