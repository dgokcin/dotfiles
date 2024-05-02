# Git configuration setups

setup-personal-git:
	$(call mkdir_safe,${HOME}/.config/git)
	$(call mkdir_safe,${XDG_CONFIG_HOME}/git)
	$(call symlink,base.gitconfig,${XDG_CONFIG_HOME}/git/config)
	$(call symlink,personal.gitconfig,${HOME}/.gitconfig)

setup-work-git:
	$(call mkdir_safe,${HOME}/.config/git)
	$(call symlink,base.gitconfig,${XDG_CONFIG_HOME}/git/config)
	$(call symlink,work.gitconfig,${HOME}/.gitconfig)
	$(call symlink,.inputrc,${HOME}/.inputrc)
