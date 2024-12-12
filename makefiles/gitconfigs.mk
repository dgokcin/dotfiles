# Git configuration setups

setup-git: ## Setup git config
	$(call mkdir_safe,${HOME}/.config/git)
	$(call mkdir_safe,${XDG_CONFIG_HOME}/git)
	$(call symlink,base.gitconfig,${XDG_CONFIG_HOME}/git/config)
	$(call symlink,work.gitconfig,${XDG_CONFIG_HOME}/git/work.gitconfig)
	$(call symlink,.inputrc,${HOME}/.inputrc)

# Kept for backward compatibility
personal-git: setup-git
work-git: setup-git