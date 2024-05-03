# Shell configuration setups

bash: ## Link common bash configuration files to the home directory
	$(call symlink,.aliases,${HOME}/.aliases)
	$(call symlink,.functions,${HOME}/.functions)
	$(call symlink,.path,${HOME}/.path)
	$(call symlink,.extra,${HOME}/.extra)
	$(call symlink,.bash_profile,${HOME}/.bash_profile)

zsh: ## Setup zsh configuration and manage oh-my-zsh and its plugins
	$(call symlink,.zshrc,${HOME}/.zshrc)
	@if [ ! -d "${HOME}/.oh-my-zsh" ]; then \
		$(call pretty_print,"Cloning oh-my-zsh..."); \
		output=$$(git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh 2>&1); \
		$(call pretty_print,"  $$output"); \
	else \
		$(call pretty_print," Updating oh-my-zsh..."); \
		output=$$(git -C ${HOME}/.oh-my-zsh pull 2>&1); \
		$(call pretty_print,"  $$output"); \
	fi
	@if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then \
		$(call pretty_print," Cloning zsh-autosuggestions..."); \
		output=$$(git clone https://github.com/zsh-users/zsh-autosuggestions.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions 2>&1); \
		$(call pretty_print,"  $$output"); \
	else \
		$(call pretty_print," Updating zsh-autosuggestions..."); \
		output=$$(git -C ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull 2>&1); \
		$(call pretty_print,"  $$output"); \
	fi
