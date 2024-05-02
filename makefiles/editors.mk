# Editor configuration setups

setup-vim:
	@$(call symlink,.vim_runtime,${HOME}/.vim_runtime)
	@$(call symlink,.vimrc,${HOME}/.vimrc)
	@$(call mkdir_safe,${HOME}/.vim/view)
	@git submodule init
	@git submodule update

setup-nvim:
	@$(call mkdir_safe,${XDG_CONFIG_HOME}/nvim)
	@for file in $(DOTFILES)/nvim/*; do \
		ln -fs $$file ${XDG_CONFIG_HOME}/nvim/; \
	done

setup-vsvim:
	$(call symlink,.vsvimrc,${HOME}/.vsvimrc)

setup-vscodevim:
	$(call symlink,.vscodevimrc,${HOME}/.vscodevimrc)

setup-ideavim:
	$(call symlink,.ideavimrc,${HOME}/.ideavimrc)

setup-gvim:
	$(call symlink,.gvimrc,${HOME}/.gvimrc)

# Define phony targets to ensure they run every time
.PHONY: setup-vim setup-nvim