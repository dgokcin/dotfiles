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
git:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -fs $(DOTFILES)/git/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/git/.gitconfig.personal ${HOME}/.gitconfig
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

install-fonts:
	curl -fLo "Ubuntu Mono Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf

install-packages:
ifeq ($(UNAME),Darwin)
	@echo "Darwin detected"
	brew update
	brew install vim git zsh curl wget
else ifeq ($(UNAME),Linux)
	@echo "Linux detected"
	sudo apt-get update
	sudo apt install -y \
		vim \
		git \
		zsh \
		curl \
		ca-certificates
	# docker
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh

	# docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-${KERNEL_NAME}-${MACHINE})" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

	# kubectl
	curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_URL}/bin/linux/amd64/kubectl"
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
	kubectl version --client
else
	@echo "Unsupported OS detected"
endif

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

personal:vim vsvim ideavim gvim nvim bash git winterm zsh vscodevim terminator
work:vim vsvim ideavim gvim nvim bash gegit winterm zsh vscodevim terminator

.PHONY: personal work clean

.DEFAULT_GOAL := personal

