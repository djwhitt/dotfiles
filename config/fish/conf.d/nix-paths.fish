for dir in /run/current-system/sw/bin /etc/profiles/per-user/$USER/bin /opt/homebrew/bin /opt/homebrew/sbin
    if test -d $dir
        fish_add_path --prepend --global $dir
    end
end
