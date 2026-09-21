#!/usr/bin/env bash
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Update dotfiles
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon 🛠️
# @raycast.packageName Dotfiles
#
# Documentation:
# @raycast.description Pull the latest dotfiles and re-run the personal layer.
# @raycast.author deniz_gokcin
# @raycast.authorURL https://raycast.com/deniz_gokcin
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/codes/dotfiles}"

cd "$DOTFILES"
git pull --ff-only
make personal
