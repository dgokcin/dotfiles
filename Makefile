DOTFILES := $(shell pwd)
UNAME := $(shell uname)
KERNEL_NAME := $(shell uname -s)
MACHINE := $(shell uname -m)
XDG_CONFIG_HOME ?= $(HOME)/.config

vim:
	git submodule init
	git submodule update
	ln -fs $(DOTFILES)/.vim_runtime ${HOME}/.vim_runtime
	ln -fs $(DOTFILES)/.vimrc ${HOME}/.vimrc
	mkdir -p ${HOME}/.vim/view

vsvim:
	ln -fs $(DOTFILES)/.vsvimrc ${HOME}/.vsvimrc

vscodevim:
	ln -fs $(DOTFILES)/.vscodevimrc ${HOME}/.vscodevimrc

ideavim:
	ln -fs $(DOTFILES)/.ideavimrc ${HOME}/.ideavimrc

gvim:
	ln -fs $(DOTFILES)/.gvimrc ${HOME}/.gvimrc

nvim:
	mkdir -p ${XDG_CONFIG_HOME}/nvim
	for file in $(DOTFILES)/nvim/*; do \
		ln -fs $$file ${XDG_CONFIG_HOME}/nvim/; \
	done

lazygit:
	mkdir -p ${XDG_CONFIG_HOME}/lazygit
	ln -fs $(DOTFILES)/other/lazygit/config.yml ${XDG_CONFIG_HOME}/lazygit/config.yml

bash:
	ln -fs $(DOTFILES)/.aliases ${HOME}/.aliases
	ln -fs $(DOTFILES)/.functions ${HOME}/.functions
	ln -fs $(DOTFILES)/.path ${HOME}/.path
	ln -fs $(DOTFILES)/.extra ${HOME}/.extra
	ln -fs $(DOTFILES)/.bash_profile ${HOME}/.bash_profile

personal-git:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -fs $(DOTFILES)/base.gitconfig ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/personal.gitconfig ${HOME}/.gitconfig

work-git:
	mkdir -p ${HOME}/.config/git
	ln -fs $(DOTFILES)/base.gitconfig ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/work.gitconfig ${HOME}/.gitconfig
	ln -fs $(DOTFILES)/.inputrc ${HOME}/.inputrc

zsh:
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc
	git -C ${HOME}/.oh-my-zsh pull || \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
	git -C ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull || \
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions

yamllint:
	mkdir -p ${HOME}/.config/yamllint
	ln -fs $(DOTFILES)/other/yamllint/config ${XDG_CONFIG_HOME}/yamllint/config

# works only on mac
iterm2:
ifeq ($(UNAME),Darwin)
	ln -fs $(DOTFILES)/other/iterm2/com.googlecode.iterm2.plist ${HOME}/Library/Preferences/
endif

# works only on linux
terminator:
ifeq ($(UNAME),Linux)
	mkdir -p ${XDG_CONFIG_HOME}/terminator
	ln -fs $(DOTFILES)/.terminator.config ${XDG_CONFIG_HOME}/terminator/config
endif

# works only on windows
winterm:
ifeq ($(UNAME),Windows_NT)
	ln -fs $(DOTFILES)/other/winterm/settings.json ${HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
endif

# update submodules
update-plugins:
	git submodule update --init --recursive

clean:
	rm -rf ${HOME}/.vim_runtime
	rm -rf ${HOME}/.vim/view/*
	rm -rf ${HOME}/.vimrc
	rm -rf ${HOME}/.vsvimrc
	rm -rf ${HOME}/.vscodesettings.json
	rm -rf ${HOME}/.gvimrc
	rm -rf ${XDG_CONFIG_HOME}/nvim
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

personal:vim vsvim vscodevim ideavim gvim nvim lazygit bash personal-git zsh yamllint iterm2 terminator winterm
work:vim vsvim vscodevim ideavim gvim nvim lazygit bash work-git zsh yamllint iterm2 terminator winterm

.PHONY: vim personal work clean nvim

.DEFAULT_GOAL := personal

