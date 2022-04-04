function _fzf_codex
    set command (
      codex-fish-completions (commandline) | \
        _fzf_wrapper \
            --tiebreak=index \
            --preview-window="bottom:3:wrap"
    )

    if test $status -eq 0
        commandline --replace -- $command
    end

    commandline --function repaint
end
