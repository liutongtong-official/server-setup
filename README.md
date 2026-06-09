# server-setup

Bootstrap a fresh server's environment in one command: shell config, dotfiles, SSH key, and language toolchains. Idempotent — safe to re-run.

## Usage

```bash
git clone <this-repo> ~/server-setup && cd ~/server-setup
./install.sh                 # run everything
./install.sh shell ssh       # run only selected modules
```

Modules (run in this order): `shell`, `dotfiles`, `ssh`, `tools`.

After it finishes, restart your shell (or `source ~/.bashrc`). The `ssh` module prints a public key — add it to GitHub under *Settings → SSH and GPG keys*.

## Layout

| Path | Role |
|---|---|
| `install.sh` | Entry point — orchestrates the modules. |
| `lib/common.sh` | Shared helpers: logging, backup, `symlink_safe`, `append_once`. |
| `shell/common.sh` | Shell config shared by bash & zsh (exports, aliases, functions). |
| `shell/bashrc`, `shell/zshrc` | Per-shell config — source `common.sh`, add shell-specific completion. |
| `dotfiles/` | `tmux.conf`, `inputrc`, `ssh_config`. |
| `modules/` | One script per concern (`<name>.sh`); run order set by `MODULES` in `install.sh`. |

## How config is applied

- **Shell** (`~/.bashrc`, `~/.zshrc`): a guarded `source` line is appended, keeping the distro defaults. The repo stays the source of truth.
- **`tmux.conf` / `inputrc`**: symlinked from `dotfiles/` (no distro default to preserve).
- **SSH**: an `Include` line is prepended to `~/.ssh/config` so versioned host config loads while machine-specific hosts stay local. An ed25519 key is generated only if missing.
- **Toolchains** (`go`, `nvm`, `uv`): installed under `$HOME` (no sudo, no global scope), skipped when already present.

## Overrides

| Variable | Default | Used by |
|---|---|---|
| `SSH_KEY_COMMENT` | `liutongtong7@gmail.com` | `ssh` |
| `GO_VERSION` | latest stable | `tools` |
| `NVM_VERSION` | latest release | `tools` |
