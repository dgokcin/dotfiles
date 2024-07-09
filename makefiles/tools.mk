# Tool configuration setups

lazygit: ## Install and configure lazygit in the user's config directory
	$(call install_with_brew,lazygit)
	$(call mkdir_safe,${XDG_CONFIG_HOME}/lazygit)
	$(call symlink,other/lazygit/config.yml,${XDG_CONFIG_HOME}/lazygit/config.yml)

yamllint: ## Set up yamllint with custom configuration in the config directory
	$(call install_with_brew,yamllint)
	$(call mkdir_safe,${HOME}/.config/yamllint)
	$(call symlink,other/yamllint/config,${XDG_CONFIG_HOME}/yamllint/config)

continue:
	$(call mkdir_safe,${HOME}/.continue)
	$(call symlink,ai-stuff/continue/config.json,${HOME}/.continue/config.json)
