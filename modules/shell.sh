# shellcheck shell=bash
# Wire the repo's shell config into ~/.bashrc and ~/.zshrc.
# rc files keep the distro defaults; we only append a guarded `source` line.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

log "configuring shell rc files"

append_once "$HOME/.bashrc" "server-setup:shell" \
  "[ -f \"$REPO_DIR/shell/bashrc\" ] && source \"$REPO_DIR/shell/bashrc\""

# Only touch ~/.zshrc if zsh is present on the box.
if command -v zsh >/dev/null 2>&1; then
  append_once "$HOME/.zshrc" "server-setup:shell" \
    "[ -f \"$REPO_DIR/shell/zshrc\" ] && source \"$REPO_DIR/shell/zshrc\""
else
  warn "zsh not installed; skipped ~/.zshrc"
fi
