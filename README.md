# ⚙️ dotfiles

Personal dotfiles and AI tooling for macOS, with a handful of Linux paths. Every
install is a symlink back into this repo, so editing a file here changes the live
configuration immediately and nothing gets copied into `$HOME`.

A shared skill library in [`ai-stuff/skills/`](ai-stuff/skills/) installs into
Claude Code, Codex, Cursor, and anything else that reads the cross-tool
`~/.agents/skills` directory. See [`ai-stuff/README.md`](ai-stuff/README.md).

## 📁 Layout

```
.
├── Makefile              entry point; includes makefiles/*.mk, defines shared macros
├── makefiles/            one .mk per concern, plus helper scripts in scripts/
├── ai-stuff/             skills, agents, personas, and per-tool AI settings
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
make claude         # native CLI, agents, hooks, settings, keybindings, skills
make cursor         # agents, hooks, settings, keybindings, skills
make codex          # standalone CLI, hooks, AGENTS.md, config, skills
make ai             # skills only, into every registered tool
```

Run `make help` for the full target list.

## 🎯 Targets

### 🖥️ Environment

| Target | Does |
| --- | --- |
| `bootstrap` | Full new-Mac setup: Homebrew bundle, runtimes, CLIs, shell, editors, and AI tools |
| `personal` | `nvim bash zsh setup-git yamllint k9s` |
| `work` | Identical to `personal` today. The split is kept for backward compatibility, and `work.gitconfig` is linked either way. |
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

### 🤖 AI

| Target | Does |
| --- | --- |
| `ai` | Run `ai-check`, link shared content, install skills into every registered tool |
| `ai-check` | Lint `SKILL.md` against `agents/openai.yaml` on invocation policy, legacy keys, and stale files |
| `ai-shared` | Link `ai-stuff/_shared` to `~/.config/ai-shared` |
| `ai-list` | Print the skill inventory and tool registry |
| `ai-skill-meta` | Scaffold a missing `agents/openai.yaml` |
| `ai-clean` | Remove installed skills everywhere |
| `claude` | Native Claude Code CLI plus agents, scripts, settings, keybindings, output styles, and `ai-claude` |
| `cursor` | Cursor agents, hook scripts, hooks.json, CLI config, editor settings, plus `ai-agents` |
| `codex` | Standalone Codex CLI plus hooks, scripts, `AGENTS.md`, managed `config.toml`, and `ai-agents` |

Skills are authored once in `ai-stuff/skills/` and symlinked verbatim into each
tool's skills directory. Adding a tool takes two lines in
[`makefiles/ai.mk`](makefiles/ai.mk), and adding a skill needs no Makefile change
at all.

### ✅ Checks

| Target | Does |
| --- | --- |
| `lint` | actionlint, shellcheck, yamllint, JSON parse check |
| `test` | Skill metadata lint plus statusline fixture tests |
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

- `ai-stuff/_shared/personas/_*.md` and `ai-stuff/_shared/config/_*.md`
- `ai-stuff/_shared/config/.clusters.json` (cluster and account names)
- `ai-stuff/_shared/config/traefik-epic.md`
