# Utility commands for maintenance and updates

# Update submodules
update-vim-plugins: ## Update vim plugins to the latest version with submodules
	git submodule update --init --recursive

# Clean configuration
clean: ## Clean up all configurations
	$(call remove_file,${HOME}/.vim_runtime)
	$(call remove_file,${HOME}/.vim/view/*)
	$(call remove_file,${HOME}/.vimrc)
	$(call remove_file,${HOME}/.vsvimrc)
	$(call remove_file,${HOME}/.vscodesettings.json)
	$(call remove_file,${HOME}/.gvimrc)
	$(call remove_file,${XDG_CONFIG_HOME}/nvim)
	$(call remove_file,${XDG_CONFIG_HOME}/terminator/config)
	$(call remove_file,${HOME}/.ideavimrc)
	$(call remove_file,${HOME}/.gvimrc)
	$(call remove_file,${HOME}/.gitconfig)
	$(call remove_file,${XDG_CONFIG_HOME}/git/config)
	$(call remove_file,${HOME}/.bash_profile)
	$(call remove_file,${HOME}/.aliases)
	$(call remove_file,${HOME}/.functions)
	$(call remove_file,${HOME}/.path)
	$(call remove_file,${HOME}/.inputrc)
	$(call remove_file,${HOME}/.zshrc)
	$(call remove_file,${HOME}/.oh-my-zsh)