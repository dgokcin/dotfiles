# ⚙️ dotfiles

Personal dotfiles and AI tooling for macOS, with a handful of Linux paths. Every
install is a symlink back into this repo, so editing a file here changes the live
configuration immediately and nothing gets copied into `$HOME`.

AI tool configuration for Claude Code, Codex, and Cursor lives in
[`ai-stuff/`](ai-stuff/README.md). Skills live in a separate repo,
[`dgokcin/skills`](https://github.com/dgokcin/skills), and `make skills`
installs them into each tool.

## 📁 Layout

```
.
├── Makefile              entry point; includes makefiles/*.mk, defines shared macros
├── makefiles/            one .mk per concern, plus helper scripts in scripts/
├── ai-stuff/             agents, shared AI content, and per-tool AI settings
├── nvim/                 Neovim config (LazyVim + lazy.nvim, Lua)
├── other/                app configs: lazygit, k9s, tmux, yamllint, vscode, winterm
├── Brewfile              Homebrew taps, formulae, casks, and fonts
├── .github/workflows/    checks.yml, release-please.yml
└── dotfiles at the root  .zshrc, .aliases, .functions, .path, .extra,
                          .bash_profile, base.gitconfig, work.gitconfig,
                          .inputrc, .osx
```

## 🚀 Quick start

```bash
git clone https://github.com/dgokcin/dotfiles.git ~/codes/dotfiles
cd ~/codes/dotfiles
make bootstrap      # packages, runtimes, CLIs, shell, editors, and AI configs
make verify-tool-owners
```

Or run the layers separately:

```bash
make brew-bundle    # Homebrew packages, casks, and fonts
make tools          # Volta/Node plus preferred standalone and npm CLIs
make personal       # shell, editors, git, and tool configs
make claude         # native CLI, agents, hooks, settings, keybindings
make cursor         # agents, hooks, settings, keybindings
make codex          # standalone CLI, hooks, AGENTS.md, config
make raycast        # script commands plus Raycast preferences (macOS)
make ai-shared      # shared AI content only, into ~/.config/ai-shared
```

Run `make help` for the full target list.

## 🎯 Targets

### 🖥️ Environment

| Target | Does |
| --- | --- |
| `bootstrap` | Full new-Mac setup: Homebrew bundle, runtimes, CLIs, shell, editors, and AI tools |
| `personal` | `nvim bash zsh setup-git yamllint k9s` |
| `work` | Identical to `personal` today. The split is kept for backward compatibility, and `work.gitconfig` is linked either way. |
| `brew-trust` | Trust the third-party taps the `Brewfile` declares (Homebrew 7 gate) |
| `brew-bundle` | Install everything in the `Brewfile` |
| `brew-bundle-check` | Report what is missing, install nothing |
| `clean` | Remove the symlinks and state this repo installs |

### 🛠️ Editors, shell, and git

| Target | Does |
| --- | --- |
| `nvim` | Symlink the Neovim config into `$XDG_CONFIG_HOME/nvim` |
| `zsh` | Link `.zshrc`, clone or update oh-my-zsh and zsh-autosuggestions |
| `bash` | Link `.aliases`, `.functions`, `.path`, `.extra`, `.bash_profile` |
| `setup-git` | Link `base.gitconfig`, `work.gitconfig`, and `.inputrc` |
| `terminator` | Linux only |

### 🧰 Tools

| Target | Preferred owner |
| --- | --- |
| `tools` | Install all runtime and CLI targets below |
| `node` | Latest Node.js LTS through Volta; npm comes from Node |
| `npm-tools` | Corepack, Gemini CLI, Clodex, and ACP adapters through Volta |
| `yarn` | Corepack shim; project `packageManager` selects the version |
| `pnpm` | Official standalone installer |
| `bun` | Official standalone installer |
| `uv` | Astral standalone installer |
| `aws-cli` | Official AWS CLI v2 installer (user-owned, no sudo) |
| `opencode-cli` | Official standalone installer |
| `claude-cli` | Anthropic native installer |
| `codex-cli` | OpenAI standalone installer |
| `verify-tool-owners` | Fail when a command resolves through the wrong installer |

Biome and TypeScript stay project-local. Pyright and TypeScript language server
belong to the editor's package manager. Tree-sitter CLI is not installed
globally; install it through Cargo only when developing grammars. Homebrew owns
macOS applications and general native command-line tools.

`lazygit`, `yamllint`, `yq`, `k9s`, and `tmux` retain individual configuration
targets that install with Homebrew where needed and link config from `other/`.

### 🔍 Raycast

| Target | Does |
| --- | --- |
| `raycast` | Run `raycast-scripts` and `raycast-defaults` (macOS only) |
| `raycast-scripts` | Symlink `other/raycast/scripts` to `~/.raycast-scripts` |
| `raycast-defaults` | Apply `com.raycast.macos` preferences, skipped while Raycast runs |
| `raycast-clean` | Remove the script directory symlink |

Raycast keeps aliases, quicklinks, snippets, and extension settings in an
encrypted database, so those move between Macs through Cloud Sync rather than
this repo. Registering the script directory is a one-time click. See
`other/raycast/README.md`.

### 🤖 AI

| Target | Does |
| --- | --- |
| `ai-shared` | Link `ai-stuff/_shared` to `~/.config/ai-shared` |
| `claude` | Native Claude Code CLI plus agents, scripts, settings, keybindings, output styles, and `ai-shared` |
| `cursor` | Cursor agents, hook scripts, hooks.json, CLI config, editor settings |
| `codex` | Standalone Codex CLI plus hooks, scripts, `AGENTS.md`, managed `config.toml` |
| `skills` | Clone `~/codes/skills`, pick skills in the `skills` CLI picker, and link them live |
| `skills-all` | Same as `skills`, but installs every skill without prompting |
| `skills-remove` | Pick installed skills to remove |
| `skills-list` | List globally installed skills |

`make skills` runs `npx skills add ~/codes/skills -g` for Claude Code, Codex,
and Cursor. The CLI copies each pick into `~/.agents/skills`, and
`makefiles/scripts/skills-link.sh` swaps those copies for symlinks into
`~/codes/skills`. Skills keep bare names like `/create-pr`, and edits apply
live. Run `make skills` again to pick up a new skill.

### ✅ Checks

| Target | Does |
| --- | --- |
| `lint` | actionlint, shellcheck, yamllint, JSON parse check |
| `test` | Statusline fixture tests |
| `test-bootstrap` | Dry-run bootstrap and assert every preferred installer is wired in |
| `install-ci` | Symlink install into an isolated `$HOME`, no brew |
| `verify-install` | Assert those symlinks point back at this repo |
| `brew-health` | Fail if `Brewfile` entries no longer resolve |

## 🔄 Continuous integration

[`checks.yml`](.github/workflows/checks.yml) runs on every pull request, on
pushes to `main`, and on a weekly schedule.

- Linux: `make lint`, `make test`, `make test-bootstrap`, then an isolated `make install-ci` and `make verify-install`.
- macOS: `make cursor-user-config` (the `~/Library` path Linux cannot cover) and `make brew-health`. The weekly run fails on stale Brewfile entries.

[`release-please.yml`](.github/workflows/release-please.yml) maintains the
version and [`CHANGELOG.md`](CHANGELOG.md) from conventional commit messages.

## 🔒 Private files

Some files are gitignored because they carry personal or work-specific detail.
The tracked file is the template, and the private variant sits beside it with a
leading underscore or a dot prefix.

- `ai-stuff/_shared/config/_*.md`
- `ai-stuff/_shared/config/.clusters.json` (cluster and account names)
- `ai-stuff/_shared/config/traefik-epic.md`
