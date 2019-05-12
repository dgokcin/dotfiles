function cd {
    builtin cd "$@" && ls -F
    }
