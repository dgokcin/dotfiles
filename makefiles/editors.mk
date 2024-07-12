# Editor configuration setups

.PHONY: nvim

nvim: ## Setup Neovim configuration by linking dotfiles
	@$(call mkdir_safe,${XDG_CONFIG_HOME}/nvim)
	@for item in $(DOTFILES)/nvim/*; do \
		if [ -d "$$item" ]; then \
			ln -sfn $$item ${XDG_CONFIG_HOME}/nvim/; \
		else \
			ln -sf $$item ${XDG_CONFIG_HOME}/nvim/; \
		fi; \
	done

vim: ## Setup Vim configuration and update submodules
	@$(call symlink,.vim_runtime,${HOME}/.vim_runtime)
	@$(call symlink,.vimrc,${HOME}/.vimrc)
	@$(call mkdir_safe,${HOME}/.vim/view)
	@git submodule init
	@git submodule update

vsvim: ## Setup VSVim configuration by linking .vsvimrc
	$(call symlink,.vsvimrc,${HOME}/.vsvimrc)

vscodevim: ## Setup VSCode Vim configuration by linking .vscodevimrc
	$(call symlink,.vscodevimrc,${HOME}/.vscodevimrc)

ideavim: ## Setup IdeaVim configuration by linking .ideavimrc
	$(call symlink,.ideavimrc,${HOME}/.ideavimrc)

gvim: ## Setup GVim configuration by linking .gvimrc
	$(call symlink,.gvimrc,${HOME}/.gvimrc)