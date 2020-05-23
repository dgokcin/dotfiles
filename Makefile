.PHONY: all
all : vim vsvim ideavim gvim zsh bash git

DOTFILES := $(shell pwd)
UNAME := $(shell uname)

vim:
	ln -fs $(DOTFILES)/.vim_runtime ${HOME}
	ln -fs $(DOTFILES)/.vimrc ${HOME}/.vimrc
vsvim:
	ln -fs $(DOTFILES)/.vsvimrc ${HOME}/.vsvimrc
ideavim:
	ln -fs $(DOTFILES)/.ideavimrc ${HOME}/.ideavimrc
gvim:
	ln -fs $(DOTFILES)/.gvimrc ${HOME}/.gvimrc
bash:
	ln -fs $(DOTFILES)/.bash_profile ${HOME}/.bash_profile
zsh:
ifneq ($(UNAME), MINGW64_NT-10.0-18363)
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc
	git -C ${HOME}/.oh-my-zsh pull || \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
endif
git:
ifneq ($(UNAME), MINGW64_NT-10.0-18363)
	ln -fs $(DOTFILES)/.gitconfig ${HOME}/.gitconfig
endif

.PHONY: clean

clean:
	rm -rf ${HOME}/.vim_runtime
	rm -rf ${HOME}/.vimrc
	rm -rf ${HOME}/.vsvimrc
	rm -rf ${HOME}/.gvimrc
	rm -rf ${HOME}/.ideavimrc
	rm -rf ${HOME}/.gvimrc
	rm -rf ${HOME}/.bash_profile
	rm -rf ${HOME}/.zshrc

