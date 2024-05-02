# Shell configuration setups

setup-bash:
	$(call symlink,.aliases,${HOME}/.aliases)
	$(call symlink,.functions,${HOME}/.functions)
	$(call symlink,.path,${HOME}/.path)
	$(call symlink,.extra,${HOME}/.extra)
	$(call symlink,.bash_profile,${HOME}/.bash_profile)

setup-zsh:
	$(call symlink,.zshrc,${HOME}/.zshrc)
	git -C ${HOME}/.oh-my-zsh pull || \
	git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
	git -C ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull || \
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions

.PHONY: setup-bash setup-zsh