# Environment-specific setups

# Disabled since the settings do not persist
# iterm2: ## Setup iTerm2 preferences for MacOS
# ifeq ($(UNAME),Darwin)
# 	@$(call symlink,other/iterm2/com.googlecode.iterm2.plist,${HOME}/Library/Preferences/)
# endif

terminator: ## Setup Terminator config for Linux
ifeq ($(UNAME),Linux)
	@$(call mkdir_safe,${XDG_CONFIG_HOME}/terminator)
	@$(call symlink,.terminator.config,${XDG_CONFIG_HOME}/terminator/config)
endif
