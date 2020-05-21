#!/bin/sh
set -e

# remove dotfiles
rm -rf ~/.bash_profile
rm -rf ~/.vimrc
rm -rf ~/.vsvimrc
rm -rf ~/.ideavimrc
rm -rf ~/.gvimrc
rm -rf ~/.vim_runtime
rm -rf ~/.zshrc

# clear .view directory
rm -rf ~/.vim/view/*

# copy current dotfiles
cp .vimrc ~/
cp -r .vim_runtime ~/
cp .bash_profile ~/
cp .vsvimrc ~/
cp .ideavimrc ~/
cp .gvimrc ~/
cp .zshrc ~/

# os specific stuff
#if [ "$(uname)" == "Darwin" ]; then
    ## Do something under Mac OS X platform
#elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    ## Do something under GNU/Linux platform
#elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    ## Do something under 32 bits Windows NT platform
#elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    ## Do something under 64 bits Windows NT platform
#fi



echo "Installed vim config, added dotfiles to the current root."
