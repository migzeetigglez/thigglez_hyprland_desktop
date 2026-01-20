function fish_right_prompt
    # Path only when not home
    set -l pwd (prompt_pwd)
    if test "$pwd" != "~"
        set_color brblack
        echo -n $pwd
        set_color normal
    end

    # Git only when in a repo
    if command -q git; and git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
        set -l dirty (command git status --porcelain 2>/dev/null)

        echo -n " "
        set_color brblack
        echo -n "git:"
        set_color AC82E9
        echo -n $branch
        set_color normal

        if test -n "$dirty"
            set_color brred
            echo -n "*"
            set_color normal
        end
    end
end
