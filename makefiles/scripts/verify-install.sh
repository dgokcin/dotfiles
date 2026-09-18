#!/usr/bin/env bash
# Assert that `make install-ci` produced live symlinks into this repo.
# HOME and XDG_CONFIG_HOME must already point at the install tree.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
HOME="${HOME:?HOME must be set}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ "$(uname -s)" == Darwin ]]; then
  cursor_user="$HOME/Library/Application Support/Cursor/User"
else
  cursor_user="$XDG_CONFIG_HOME/Cursor/User"
fi

fail=0
ok=0

pass() { printf '  ok     %s\n' "$1"; ok=$((ok + 1)); }
fail_at() { printf '  FAIL   %s\n' "$1"; fail=$((fail + 1)); }

assert_link() {
  local dest="$1" expected="$2"
  if [[ ! -L "$dest" ]]; then
    fail_at "$dest is not a symlink"
    return
  fi
  local actual
  actual="$(readlink "$dest")"
  if [[ "$actual" != "$expected" ]]; then
    fail_at "$dest -> $actual (expected $expected)"
    return
  fi
  if [[ ! -e "$dest" ]]; then
    fail_at "$dest is a dangling symlink -> $actual"
    return
  fi
  pass "$dest"
}

assert_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    pass "$path"
  else
    fail_at "$path is missing"
  fi
}

assert_contains() {
  local file="$1" needle="$2"
  if [[ -f "$file" ]] && grep -F -q "$needle" "$file"; then
    pass "$file has '$needle'"
  else
    fail_at "$file is missing '$needle'"
  fi
}

echo "verify-install: HOME=$HOME"
echo "verify-install: repo=$REPO"

assert_link "$HOME/.zshrc" "$REPO/.zshrc"
assert_link "$HOME/.aliases" "$REPO/.aliases"
assert_link "$HOME/.functions" "$REPO/.functions"
assert_link "$HOME/.path" "$REPO/.path"
assert_link "$HOME/.bash_profile" "$REPO/.bash_profile"
assert_link "$HOME/.ideavimrc" "$REPO/.ideavimrc"
assert_link "$HOME/.inputrc" "$REPO/.inputrc"
assert_link "$XDG_CONFIG_HOME/git/config" "$REPO/base.gitconfig"
assert_link "$XDG_CONFIG_HOME/git/work.gitconfig" "$REPO/work.gitconfig"
assert_link "$XDG_CONFIG_HOME/k9s/aliases.yaml" "$REPO/other/k9s/aliases.yaml"
assert_link "$XDG_CONFIG_HOME/nvim/init.lua" "$REPO/nvim/init.lua"
assert_link "$XDG_CONFIG_HOME/ai-shared" "$REPO/ai-stuff/_shared"

assert_link "$HOME/.claude/settings.json" "$REPO/ai-stuff/claude/settings.json"
assert_link "$HOME/.claude/keybindings.json" "$REPO/ai-stuff/claude/keybindings.json"
assert_link "$HOME/.claude/scripts/statusline.sh" "$REPO/ai-stuff/claude/scripts/statusline.sh"
assert_link "$HOME/.claude/scripts/auto-approve-tools.sh" "$REPO/ai-stuff/_shared/scripts/auto-approve-tools.sh"
assert_link "$HOME/.claude/agents/gitboi.md" "$REPO/ai-stuff/agents/gitboi.md"
assert_link "$HOME/.claude/skills/auto-commit" "$REPO/ai-stuff/skills/auto-commit"

assert_link "$HOME/.cursor/hooks.json" "$REPO/ai-stuff/cursor/hooks.json"
assert_link "$HOME/.cursor/cli-config.json" "$REPO/ai-stuff/cursor/cli-config.json"
assert_link "$HOME/.cursor/scripts/auto-approve-cursor.sh" "$REPO/ai-stuff/cursor/scripts/auto-approve-cursor.sh"
assert_link "$cursor_user/settings.json" "$REPO/ai-stuff/cursor/settings.json"
assert_link "$cursor_user/keybindings.json" "$REPO/ai-stuff/cursor/keybindings.json"

assert_link "$HOME/.agents/skills/auto-commit" "$REPO/ai-stuff/skills/auto-commit"
assert_link "$HOME/.codex/hooks.json" "$REPO/ai-stuff/codex/hooks.json"
assert_link "$HOME/.codex/AGENTS.md" "$REPO/ai-stuff/codex/AGENTS.md"
assert_link "$HOME/.codex/RTK.md" "$REPO/ai-stuff/codex/RTK.md"
assert_link "$HOME/.codex/scripts/notify-stop.sh" "$REPO/ai-stuff/codex/scripts/notify-stop.sh"
assert_contains "$HOME/.codex/config.toml" "BEGIN dotfiles-managed"

assert_exists "$HOME/.oh-my-zsh"
assert_exists "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

skill_count="$(/usr/bin/find "$HOME/.claude/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')"
if [[ "$skill_count" -ge 10 ]]; then
  pass "claude skills ($skill_count)"
else
  fail_at "expected >= 10 claude skills, found $skill_count"
fi

echo
echo "verify-install: $ok passed, $fail failed"
(( fail == 0 ))
