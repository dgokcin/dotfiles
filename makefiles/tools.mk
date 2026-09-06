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

continue:
	$(call mkdir_safe,${HOME}/.continue)
	$(call symlink,ai-stuff/continue/config.json,${HOME}/.continue/config.json)

karabiner:
	$(call mkdir_safe,${HOME}/.config/karabiner)
	$(call symlink,other/karabiner/karabiner.json,${HOME}/.config/karabiner/karabiner.json)

tmux: ## Install tmux and symlink config (fixes TERM/escape-sequence bleed with vim)
	$(call install_with_brew,tmux)
	$(call symlink,other/tmux/tmux.conf,${HOME}/.tmux.conf)
