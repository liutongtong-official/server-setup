# shellcheck shell=bash
# Symlink standalone dotfiles that have no distro-provided default.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

log "linking dotfiles"

symlink_safe "$REPO_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"
symlink_safe "$REPO_DIR/dotfiles/inputrc"   "$HOME/.inputrc"
