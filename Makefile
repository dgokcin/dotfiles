DOTFILES := $(shell pwd)
UNAME := $(shell uname)


vim:
	mkdir -p ${HOME}/.vim/view
	ln -fs $(DOTFILES)/.vim_runtime ${HOME}
	ln -fs $(DOTFILES)/.vimrc ${HOME}/.vimrc
vsvim:
	ln -fs $(DOTFILES)/.vsvimrc ${HOME}/.vsvimrc
ideavim:
	ln -fs $(DOTFILES)/.ideavimrc ${HOME}/.ideavimrc
gvim:
	ln -fs $(DOTFILES)/.gvimrc ${HOME}/.gvimrc
bash:
	ln -fs $(DOTFILES)/.aliases ${HOME}/.aliases
	ln -fs $(DOTFILES)/.functions ${HOME}/.functions
	ln -fs $(DOTFILES)/.bash_profile ${HOME}/.bash_profile
git:
	ln -fs $(DOTFILES)/.gitconfig.str ~/.config/git/gitconfig
ifneq ($(UNAME), MINGW64_NT-10.0-18363)
	ln -fs $(DOTFILES)/.gitconfig.personal ${HOME}/.gitconfig
else
	ln -fs $(DOTFILES)/.gitconfig.work ${HOME}/.gitconfig
endif
winter:
ifeq ($(OS),Windows_NT)
	ln -fs $(DOTFILES)/settings.json ${HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
endif
zsh:
ifneq ($(UNAME), MINGW64_NT-10.0-18363)
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc
	git -C ${HOME}/.oh-my-zsh pull || \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
endif


clean:
	rm -rf ${HOME}/.vim_runtime
	rm -rf ${HOME}/.vim/view/*
	rm -rf ${HOME}/.vimrc
	rm -rf ${HOME}/.vsvimrc
	rm -rf ${HOME}/.gvimrc
	rm -rf ${HOME}/.ideavimrc
	rm -rf ${HOME}/.gvimrc
	rm -rf ${HOME}/.bash_profile
	rm -rf ${HOME}/.aliases
	rm -rf ${HOME}/.functions
	rm -rf ${HOME}/.zshrc

all: vim vsvim ideavim gvim bash git winter zsh

.PHONY: all clean

.DEFAULT_GOAL := all

