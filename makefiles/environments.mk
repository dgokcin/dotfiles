# Environment-specific setups

setup-iterm2:
ifeq ($(UNAME),Darwin)
	@$(call symlink,other/iterm2/com.googlecode.iterm2.plist,${HOME}/Library/Preferences/)
endif

setup-terminator:
ifeq ($(UNAME),Linux)
	@$(call mkdir_safe,${XDG_CONFIG_HOME}/terminator)
	@$(call symlink,.terminator.config,${XDG_CONFIG_HOME}/terminator/config)
endif

.PHONY: setup-iterm2 setup-terminator