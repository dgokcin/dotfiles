# Raycast configuration setup (macOS only)
#
# Raycast keeps almost all of its state (aliases, quicklinks, snippets,
# extension settings, AI presets) in an encrypted sqlite database under
# ~/Library/Application Support/com.raycast.macos, which does not symlink into
# a dotfiles repo. Two surfaces are reproducible and this layer owns both:
# script commands (plain files) and the preferences plist (defaults writes).
# Registering the script directory is a one-time click in Raycast's UI.
# See other/raycast/README.md.

RAYCAST_SCRIPTS := ${HOME}/.raycast-scripts

raycast: raycast-scripts raycast-defaults ## Install Raycast script commands and preferences (macOS)

raycast-scripts: ## Symlink the tracked Raycast script commands directory
ifeq ($(UNAME),Darwin)
	$(call pretty_print, "Installing Raycast script commands...")
	@ln -sfn "$(DOTFILES)/other/raycast/scripts" "$(RAYCAST_SCRIPTS)"
	@echo "Add $(RAYCAST_SCRIPTS) under Raycast > Extensions > + > Script Directory (one time)"
else
	@echo "raycast-scripts: macOS only, skipping"
endif

raycast-defaults: ## Apply Raycast preferences (requires Raycast to be quit)
ifeq ($(UNAME),Darwin)
	$(call pretty_print, "Applying Raycast preferences...")
	@$(DOTFILES)/other/raycast/defaults.sh
else
	@echo "raycast-defaults: macOS only, skipping"
endif

raycast-clean: ## Remove the Raycast script directory symlink
	$(call pretty_print, "Removing Raycast symlinks...")
	@[ ! -L "$(RAYCAST_SCRIPTS)" ] || rm -f "$(RAYCAST_SCRIPTS)"

.PHONY: raycast raycast-scripts raycast-defaults raycast-clean
