# include .bashrc if it exists
if [ -f $HOME/.aliases ]; then
    . $HOME/.aliases
fi

if [ -f $HOME/.functions ]; then
    . $HOME/.functions
fi
