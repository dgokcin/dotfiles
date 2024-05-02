# Tool configuration setups

setup-lazygit:
	$(call mkdir_safe,${XDG_CONFIG_HOME}/lazygit)
	$(call symlink,other/lazygit/config.yml,${XDG_CONFIG_HOME}/lazygit/config.yml)

setup-yamllint:
	$(call mkdir_safe,${HOME}/.config/yamllint)
	$(call symlink,other/yamllint/config,${XDG_CONFIG_HOME}/yamllint/config)

.PHONY: setup-lazygit setup-yamllint