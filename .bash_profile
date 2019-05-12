#############
# Functions #
#############
function cd {
    builtin cd "$@" && ls -F
    }
###########
# Aliases #
###########
alias la="ls -a"
