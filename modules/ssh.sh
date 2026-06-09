# shellcheck shell=bash
# Generate the GitHub SSH key (if missing) and wire the repo's ssh config in
# via an Include line, keeping any machine-specific hosts in ~/.ssh/config.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SSH_DIR="$HOME/.ssh"
KEY="$SSH_DIR/github-liutongtong-official"
KEY_COMMENT="${SSH_KEY_COMMENT:-liutongtong7@gmail.com}"

log "configuring ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$KEY" ]; then
  ok "ssh key already exists: $KEY"
else
  ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$KEY" -N ""
  ok "generated ssh key: $KEY"
fi

# Make ssh load our versioned host config. Include is first-match-wins and is
# processed where it appears, so it must precede any Host block — prepend it.
prepend_once "$SSH_DIR/config" "server-setup:ssh" "Include $REPO_DIR/dotfiles/ssh_config"
chmod 600 "$SSH_DIR/config"

log "add this public key to GitHub (Settings → SSH and GPG keys):"
cat "$KEY.pub"
