.PHONY: vim vsvim ideavim gvim zsh bash
all: .PHONY

DOTFILES := $(shell pwd)

vim:
	ln -fs $(DOTFILES)/.vim_runtime ${HOME}/.vim_runtime
	ln -fs $(DOTFILES)/.vimrc ${HOME}/.vimrc
vsvim:
	ln -fs $(DOTFILES)/.vsvimrc ${HOME}/.vsvimrc
ideavim:
	ln -fs $(DOTFILES)/.ideavimrc ${HOME}/.ideavimrc
gvim:
	ln -fs $(DOTFILES)/.gvimrc ${HOME}/.gvimrc
zsh:
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc
bash:
	ln -fs $(DOTFILES)/.bash_profile ${HOME}/.bash_profile




#dev:
	#mkdir -p $(HOME)/src
#fish:
	#mkdir -p ${HOME}/.config/fish/functions
	#ln -fs $(DOTFILES)/fish/config ${HOME}/.config/fish/config.fish
	#$(shell for f in $(DOTFILES)/fish/functions/*; do ln -fs $$f ~/.config/fish/functions/; done)
#shell:
	#ln -fs ${DOTFILES}/env ${HOME}/.env
	#mkdir -p ${HOME}/.local/bin
	#ln -fs $(DOTFILES)/bin/* ${HOME}/.local/bin/
	#ln -fs ${DOTFILES}/sh/alias ${HOME}/.alias
	#ln -fs $(DOTFILES)/sh/profile ${HOME}/.profile
	#mkdir -p ${HOME}/.local/share/z
	#ln -fs $(DOTFILES)/share/z.sh ${HOME}/.local/share/z/z.sh
	#ln -fs $(DOTFILES)/sh/z.sh ${HOME}/.z.sh
#bash: shell
	#ln -fs $(DOTFILES)/bash/bashrc ${HOME}/.bashrc
	#ln -fs $(DOTFILES)/bash/bashenv ${HOME}/.bashenv
	#ln -fs $(DOTFILES)/bash/bashrc ${HOME}/.bashrc
	#ln -fs ${HOME}/.alias ${HOME}/.bashalias
#zsh: shell
	#ln -fs $(DOTFILES)/zsh/zshrc ${HOME}/.zshrc
	#ln -fs $(DOTFILES)/zsh/zlogout ${HOME}/.zlogout
	#ln -fs $(DOTFILES)/zsh/zshenv ${HOME}/.zshenv
	#mkdir -p ${HOME}/.config/zsh/
	#ln -fs $(DOTFILES)/zsh/fzf.zsh ${HOME}/.config/zsh/fzf.zsh
	#ln -fs $(DOTFILES)/zsh/zshenv ${HOME}/.zshenv
	#git -C ${HOME}/.oh-my-zsh pull || \
		#git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
	#git -C ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k pull || \
		#git clone https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
	#git -C ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull || \
		#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	#git -C ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull || \
		#git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#screen:
	#ln -fs $(DOTFILES)/rc/screenrc ${HOME}/.screenrc
#tmux:
	#ln -fs $(DOTFILES)/rc/tmux.conf ${HOME}/.tmux.conf
#vim:
	#touch ${HOME}/.netrc
	#mkdir -p ${HOME}/.cache/nvim/undo
	#mkdir -p ${HOME}/.config/nvim/
	#ln -fns $(DOTFILES)/vim ${HOME}/.vim
	#ln -fs $(DOTFILES)/nvim/init.vim ${HOME}/.config/nvim/init.vim
	#ln -fs $(DOTFILES)/nvim/init.vim ${HOME}/.vimrc
	#mkdir -p $(HOME)/.local/share/nvim/site/autoload
	#ln -fs $(DOTFILES)/vim/autoload/plug.vim ${HOME}/.local/share/nvim/site/autoload/plug.vim
	#mkdir -p $(HOME)/.local/share/nvim/plugged
	#mkdir -p $(HOME)/.local/share/nvim/min
	#ln -fs $(DOTFILES)/nvim/min.vim ${HOME}/.config/nvim/min.vim
	#ln -fs $(DOTFILES)/nvim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
	#nvim --headless +PlugInstall +qa || echo 'no nvim installed or command failed'
	#vim -E -c "PlugInstall" -c "qa" || echo 'no vim installed or command failed'
	#ln -fns $(DOTFILES)/ctags ${HOME}/.ctags.d
#X:
	#ln -fs $(DOTFILES)/rc/Xresources ${HOME}/.Xresources
	#ln -fs $(DOTFILES)/rc/Xresources ${HOME}/.Xdefaults
	#ln -fs $(DOTFILES)/rc/xinitrc ${HOME}/.xinitrc
	#ln -fs $(DOTFILES)/rc/xsessionrc ${HOME}/.xsessionrc
	#ln -fs $(DOTFILES)/rc/xscreensaver ${HOME}/.xscreensaver
#ruby:
	#ln -fs $(DOTFILES)/ruby/irbrc ${HOME}/.irbrc
	#ln -fs $(DOTFILES)/ruby/pryrc ${HOME}/.pryrc
	#ln -fs $(DOTFILES)/ruby/rdebugrc ${HOME}/.rdebugrc
	#ln -fs ${DOTFILES}/ruby/gemrc ${HOME}/.gemrc
	#ln -fs ${DOTFILES}/ruby/rspec ${HOME}/.rspec
#git:
	#ln -fs $(DOTFILES)/git/gitconfig ${HOME}/.gitconfig
	#ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore
	#ln -fs $(DOTFILES)/git/gitcommit ${HOME}/.gitcommit
#chunk:
	#ln -fs $(DOTFILES)/chunk/skhdrc ${HOME}/.skhdrc
	#ln -fs $(DOTFILES)/chunk/chunkwmrc ${HOME}/.chunkwmrc
#i3:
	#mkdir -p ${HOME}/.config/i3
	#ln -fs $(DOTFILES)/i3/config ${HOME}/.config/i3/config
#polybar:
	#mkdir -p ${HOME}/.config/polybar
	#ln -fs $(DOTFILES)/polybar/config ${HOME}/.config/polybar/config
	#ln -fs $(DOTFILES)/polybar/launch.sh ${HOME}/.config/polybar/launch.sh
#oni:
	#mkdir -p ${HOME}/.config/oni
	#ln -fs $(DOTFILES)/oni/config.js ${HOME}/.config/oni/config.js
	#ln -fs $(DOTFILES)/oni/config.tsx ${HOME}/.config/oni/config.tsx
#bspwm:
	#mkdir -p ${HOME}/.config/bspwm
	#mkdir -p ${HOME}/.config/sxhkd
	#touch ${HOME}/.xsession
	#ln -fs $(DOTFILES)/bspwm/bspwmrc ${HOME}/.config/bspwm/bspwmrc
	#ln -fs $(DOTFILES)/bspwm/sxhkdrc ${HOME}/.config/sxhkd/sxhkdrc
#kitty:
	#mkdir -p ${HOME}/.config/kitty
	#ln -fs $(DOTFILES)/kitty/kittyconf ${HOME}/.config/kitty/kitty.conf
#alacritty:
	#mkdir -p ${HOME}/.config/alacritty
	#ln -fs $(DOTFILES)/alacritty/alacritty.yml ${HOME}/.config/alacritty
#ifeq (${OS},OSX)
#qute:
	#mkdir -p ${HOME}/.qutebrowser
	#ln -fs $(DOTFILES)/qute/config.py ${HOME}/.qutebrowser/config.py
#else
#qute:
	#mkdir -p ${HOME}/.config/qutebrowser
	#ln -fs $(DOTFILES)/qute/config.py ${HOME}/.config/qutebrowser/config.py
#endif
