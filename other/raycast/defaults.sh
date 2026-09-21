#!/usr/bin/env bash
# Apply the Raycast preferences that live in com.raycast.macos.plist.
# Everything else (aliases, quicklinks, snippets, extension settings) is stored
# in Raycast's encrypted sqlite and only moves via Cloud Sync or a .rayconfig
# export. See other/raycast/README.md.
set -euo pipefail

DOMAIN="com.raycast.macos"

if [[ "$(uname -s)" != Darwin ]]; then
  echo "raycast-defaults: macOS only, skipping"
  exit 0
fi

# Raycast rewrites its plist on quit, so writes made while it runs are lost.
if pgrep -xq Raycast; then
  echo "raycast-defaults: Raycast is running and overwrites its plist on exit."
  echo "raycast-defaults: quit it and re-run 'make raycast-defaults'. Skipping."
  exit 0
fi

write() {
  local key="$1" type="$2" value="$3"
  defaults write "$DOMAIN" "$key" "$type" "$value"
  printf '  set %s = %s\n' "$key" "$value"
}

# Cmd+Space as the global hotkey (49 is the keycode for space).
write raycastGlobalHotkey -string "Command-49"

write raycastCurrentThemeId -string "bundled-raycast-dark"
write raycastCurrentThemeIdDarkAppearance -string "bundled-raycast-dark"
write raycastShouldFollowSystemAppearance -bool false
write raycastPreferredWindowMode -string "compact"
write fileSearch_fileSearchScope -string "kMDQueryScopeHome"

# Defaults for the Create Script Command form.
write create-script-command-author -string "deniz_gokcin"
write create-script-command-authorURL -string "https://raycast.com/deniz_gokcin"
write script-command-mode -string "Full Output"

echo "raycast-defaults: done, relaunch Raycast to pick these up"
