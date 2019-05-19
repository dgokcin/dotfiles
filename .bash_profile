#############
# Functions #
#############
function cl {
    builtin cd "$@" && ls -F
    }
md () {
    mkdir -p $1 && cd $1
}
cim () {
    vim $1
}
###########
# Aliases #
###########
alias la="ls -a"
