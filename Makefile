DOTFILES := $(shell pwd)
UNAME := $(shell uname)
XDG_CONFIG_HOME ?= $(HOME)/.config


install-packages:
ifeq ($(UNAME),Darwin)
	@echo "Darwin detected"
	brew update
	brew install \
		vim \
		git \
		zsh \
		curl \
		wget \
else
	@echo "Linux detected. Assuming there's an apt binary though."	
	sudo apt-get update
	sudo apt install -y \
		vim \
		git \
		zsh \
		curl \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common
	 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	 sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	sudo apt-get update
	sudo apt-get install \
		docker-ce \
	   	docker-ce-cli \
	   	containerd.io
	curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
	kubectl version --client

endif

vim:
	ln -fs $(DOTFILES)/vim/.vim_runtime ${HOME}/.vim_runtime
	ln -fs $(DOTFILES)/vim/.vimrc ${HOME}/.vimrc
	mkdir -p ${HOME}/.vim/view
vsvim:
	ln -fs $(DOTFILES)/ide/vs/.vsvimrc ${HOME}/.vsvimrc
vscode:
	git -C ${DOTFILES}/ide/vscode/vscode-settings pull || \
	git clone https://gist.github.com/84196e5d3c71a45750d3eda70353cbe1.git ${DOTFILES}/ide/vscode/vscode-settings
ifeq ($(UNAME),Darwin)
	@echo "Darwin detected"
	ln -fs $(DOTFILES)/ide/vscode/vscode-settings/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
else ifeq ($(OS),Windows_NT)
	@echo "Windows detected"
	ln -fs $(DOTFILES)/ide/vscode/vscode-settings/settings.json ${APPDATA}/Code/User/settings.json
endif


ideavim:
	ln -fs $(DOTFILES)/ide/intellij/.ideavimrc ${HOME}/.ideavimrc
gvim:
	ln -fs $(DOTFILES)/vim/.gvimrc ${HOME}/.gvimrc
nvim:
	mkdir -p ${XDG_CONFIG_HOME}/nvim
	ln -fs $(DOTFILES)/vim/.init.vim ${XDG_CONFIG_HOME}/nvim/init.vim
bash:
	ln -fs $(DOTFILES)/bash/.aliases ${HOME}/.aliases
	ln -fs $(DOTFILES)/bash/.functions ${HOME}/.functions
	ln -fs $(DOTFILES)/bash/.path ${HOME}/.path
	ln -fs $(DOTFILES)/bash/.bash_profile ${HOME}/.bash_profile
git:
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -fs $(DOTFILES)/git/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/git/.gitconfig.personal ${HOME}/.gitconfig
gegit:
	ln -fs $(DOTFILES)/git/.gitconfig.str ${XDG_CONFIG_HOME}/git/config
	ln -fs $(DOTFILES)/git/.gitconfig.work ${HOME}/.gitconfig
	ln -fs $(DOTFILES)/git/.inputrc ${HOME}/.inputrc
winter:
# ge-dell
ifeq ($(OS),Windows_NT)
	ln -fs $(DOTFILES)/winter/settings.json ${APPDATA}/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
endif
zsh:
	mkdir -p ${HOME}/.config/git
# wsl,linux or mac
ifeq ($(UNAME),$(filter $(UNAME),Darwin Linux))
	ln -fs $(DOTFILES)/bash/.zshrc ${HOME}/.zshrc
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

personal:vim vsvim ideavim gvim nvim bash git winter zsh vscode
work:vim vsvim ideavim gvim nvim bash gegit winter zsh

.PHONY: personal work clean

.DEFAULT_GOAL := personal

