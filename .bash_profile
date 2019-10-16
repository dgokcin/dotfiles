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
		else
			git commit -m "${argv[-1]}" 
			# mingw, cygwin
		fi
		git push origin
		return 1
	done
	echo not enough input arguments
}

# => For handling common typos that I make all the time
cim () {
    vim $1
}

bim () {
    vim $1
}

ci () {
    vi $1
}

bi () {
    vi $1
}

# => Zips the given parameter
zipf () {
    zip -r "$1".zip "$1" ;
}

# => Extract most know archives with one command
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH

# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH

# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH
