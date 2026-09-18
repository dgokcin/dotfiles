# Tool configuration setups

lazygit: ## Install and configure lazygit in the user's config directory
	$(call install_with_brew,lazygit)
	$(call mkdir_safe,${XDG_CONFIG_HOME}/lazygit)
	$(call symlink,other/lazygit/config.yml,${XDG_CONFIG_HOME}/lazygit/config.yml)

yamllint: ## Set up yamllint with custom configuration in the config directory
	$(call install_with_brew,yamllint)
	$(call mkdir_safe,${HOME}/.config/yamllint)
	$(call symlink,other/yamllint/config,${XDG_CONFIG_HOME}/yamllint/config)

yq: ## Install yq (YAML processor used by makefiles/scripts/skill-meta.sh)
	$(call install_with_brew,yq)

k9s: ## Symlink k9s aliases
	$(call mkdir_safe,${XDG_CONFIG_HOME}/k9s)
	$(call symlink,other/k9s/aliases.yaml,${XDG_CONFIG_HOME}/k9s/aliases.yaml)

tmux: ## Install tmux and symlink config (fixes TERM/escape-sequence bleed with vim)
	$(call install_with_brew,tmux)
	$(call symlink,other/tmux/tmux.conf,${HOME}/.tmux.conf)

brew-bundle: ## Install packages and applications from Brewfile
	@command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
	@HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$(DOTFILES)/Brewfile"

brew-bundle-check: ## Check packages and applications from Brewfile
	@command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
	@brew bundle check --file="$(DOTFILES)/Brewfile"

.PHONY: lazygit yamllint yq k9s tmux brew-bundle brew-bundle-check
