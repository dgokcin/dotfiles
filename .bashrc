###############################################################
# => Aliases
###############################################################
# Lists everything in a directory
alias la="ls -a"

# Go back 1 directory level (for fast typers)
alias cd..='cd ../'
alias ..='cd ../' 

# Quickly search for file
alias qfind="find . -name "

# Quickly edit vimrc and bashrc
alias vimrc='vim ~/.vim_runtime/my_configs.vim'
alias bashrc='vim ~/.bashrc'

# Alias for moby vm
alias moby="screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty"
# Alias for quick access to icloud drive
alias cloud="cd ~/iCloud/com~apple~CloudDocs/"

# Graphical git log.
alias tlog="git log --all --decorate --oneline --graph"

###############################################################
# => Functions
###############################################################
# => Changes directory and lists everything.
function cl {
    builtin cd "$@" && ls -a
    }

# => Makes a new directory and cds to it
mcd () {
    mkdir -p $1 && cd $1
}

# => Lazy git
function gacp {
	argc=$#
	argv=("$@")
	while [ $argc -gt 0 ]
	do	
		if [ $argc -gt 1 ]
		then
			for (( i=0;i<$(($argc-1));i++ ))
			do
				git add ${argv[i]}
			done
		else
			git add .
		fi
		if [ $(uname) == "Darwin" -o $(uname) == "Linux" ]
		then  
			git commit -m "${argv[*]: -1}"
}
