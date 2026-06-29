function fish_jj_prompt --description 'Print jj status for the prompt'
    # If jj isn't installed, let the calling prompt fall through to git/hg.
    if not command -sq jj
        return 1
    end

    # --ignore-working-copy keeps the prompt from snapshotting on every render.
    #
    # jj almost always leaves you on a fresh empty working-copy commit, so when @
    # is empty we show the parent's bookmark/description (prefixed with ◌) instead
    # of an uninformative "(empty) (no description)".
    set -l info "$(
        jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions @ \
            --template '
                separate(" ",
                    change_id.shortest(8),
                    if(empty,
                        separate(" ",
                            label("empty", "◌"),
                            parents.map(|p| separate(" ",
                                p.bookmarks().join(","),
                                if(p.description(), p.description().first_line(), label("empty", "(no description)")),
                            )),
                        ),
                        separate(" ",
                            bookmarks.join(","),
                            if(description, description.first_line(), label("empty", "(no description)")),
                        ),
                    ),
                    if(divergent, label("divergent", "??")),
                    if(conflict, label("conflict", "×")),
                )
            '
    )"
    or return 1

    if test -n "$info"
        printf ' (%s)' $info
    end
end
