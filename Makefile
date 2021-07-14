DOTFILES := $(shell pwd)
UNAME := $(shell uname)
KERNEL_NAME := $(shell uname -s)
MACHINE := $(shell uname -m)
XDG_CONFIG_HOME ?= $(HOME)/.config
KUBECTL_URL := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)


vim:
	git submodule init
	git submodule update
	ln -fs $(DOTFILES)/vim/.vim_runtime ${HOME}/.vim_runtime
	ln -fs $(DOTFILES)/vim/.vimrc ${HOME}/.vimrc
	mkdir -p ${HOME}/.vim/view
vsvim:
	ln -fs $(DOTFILES)/ide/vs/.vsvimrc ${HOME}/.vsvimrc
vscodevim:
	ln -fs $(DOTFILES)/ide/vscode/.vscodevimrc ${HOME}/.vscodevimrc
ideavim:
	ln -fs $(DOTFILES)/ide/intellij/.ideavimrc ${HOME}/.ideavimrc
gvim:
	ln -fs $(DOTFILES)/vim/.gvimrc ${HOME}/.gvimrc
nvim:
	mkdir -p ${XDG_CONFIG_HOME}/nvim
	ln -fs $(DOTFILES)/vim/.init.vim ${XDG_CONFIG_HOME}/nvim/init.vim
bash:
	ln -fs $(DOTFILES)/terminal/.aliases ${HOME}/.aliases
	ln -fs $(DOTFILES)/terminal/.functions ${HOME}/.functions
	ln -fs $(DOTFILES)/terminal/.path ${HOME}/.path
	ln -fs $(DOTFILES)/terminal/.extra ${HOME}/.extra
	ln -fs $(DOTFILES)/terminal/.bash_profile ${HOME}/.bash_profile
	cp $(DOTFILES)/com.googlecode.iterm2.plist ${HOME}/Library/Preferences/

git:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -fs $(DOTFILES)/git/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/git/.gitconfig.personal ${HOME}/.gitconfig
yamllint:
	mkdir -p ${HOME}/.config/yamllint
	ln -fs $(DOTFILES)/yamllint/config ${XDG_CONFIG_HOME}/yamllint/config
gegit:
	mkdir -p ${HOME}/.config/git
	ln -fs $(DOTFILES)/git/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/git/.gitconfig.work ${HOME}/.gitconfig
	ln -fs $(DOTFILES)/git/.inputrc ${HOME}/.inputrc
zsh:
	ln -fs $(DOTFILES)/terminal/.zshrc ${HOME}/.zshrc
	git -C ${HOME}/.oh-my-zsh pull || \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
terminator:
ifeq ($(UNAME),Linux)
	mkdir -p ${XDG_CONFIG_HOME}/terminator
	ln -fs $(DOTFILES)/terminal/.terminator.config ${XDG_CONFIG_HOME}/terminator/config
endif
winterm:
# ge-dell
ifeq ($(UNAME),Windows_NT)
	ln -fs $(DOTFILES)/winterm/settings.json ${HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
endif

update-plugins:
	git submodule foreach "git fetch && git reset --hard origin/master"

clean:
	rm -rf ${HOME}/.vim_runtime
	rm -rf ${HOME}/.vim/view/*
	rm -rf ${HOME}/.vimrc
	rm -rf ${HOME}/.vsvimrc
	rm -rf ${HOME}/.vscodesettings.json
	rm -rf ${HOME}/.gvimrc
	rm -rf ${XDG_CONFIG_HOME}/nvim/init.vim
	rm -rf ${XDG_CONFIG_HOME}/terminator/config
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
	rm -rf ${HOME}/.oh-my-zsh

personal:vim vsvim ideavim gvim nvim bash git winterm zsh vscodevim terminator yamllint
work:vim vsvim ideavim gvim nvim bash gegit winterm zsh vscodevim terminator

.PHONY: vim personal work clean

.DEFAULT_GOAL := personal

