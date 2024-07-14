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

ideavim: ## Setup IdeaVim configuration by linking .ideavimrc
	$(call symlink,.ideavimrc,${HOME}/.ideavimrc)

gvim: ## Setup GVim configuration by linking .gvimrc
	$(call symlink,.gvimrc,${HOME}/.gvimrc)