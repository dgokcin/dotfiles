DOTFILES := $(shell pwd)
UNAME := $(shell uname)
XDG_CONFIG_HOME ?= $(HOME)/.config


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
nvim:
	mkdir -p ${XDG_CONFIG_HOME}/nvim
	ln -fs $(DOTFILES)/.init.vim ${XDG_CONFIG_HOME}/nvim/init.vim
bash:
	ln -fs $(DOTFILES)/.aliases ${HOME}/.aliases
	ln -fs $(DOTFILES)/.functions ${HOME}/.functions
	ln -fs $(DOTFILES)/.path ${HOME}/.path
	ln -fs $(DOTFILES)/.bash_profile ${HOME}/.bash_profile
git:
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -fs $(DOTFILES)/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/.gitconfig.personal ${HOME}/.gitconfig
gegit:
	ln -fs $(DOTFILES)/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/.gitconfig.work ${HOME}/.gitconfig
	ln -fs $(DOTFILES)/.inputrc ${HOME}/.inputrc
winter:
# ge-dell
ifeq ($(OS),Windows_NT)
	ln -fs $(DOTFILES)/settings.json ${HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
endif
zsh:
	mkdir -p ${HOME}/.config/git
# wsl,linux or mac
ifeq ($(UNAME),$(filter $(UNAME),Darwin Linux))
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
	rm -rf ${XDG_CONFIG_HOME}/nvim/init.vim
	rm -rf ${HOME}/.ideavimrc
	rm -rf ${HOME}/.gvimrc
	rm -rf ${HOME}/.gitconfig
	rm -rf ${XDG_CONFIG_HOME}/git/config
	rm -rf ${HOME}/.bash_profile
	rm -rf ${HOME}/.aliases
	rm -rf ${HOME}/.functions
	rm -rf ${HOME}/.path
	rm -rf ${HOME}/.inputrc
	rm -rf ${HOME}/.zshrc

personal: vim vsvim ideavim gvim nvim bash git winter zsh
work: vim vsvim ideavim gvim nvim bash gegit winter zsh

.PHONY: personal work clean

.DEFAULT_GOAL := personal

