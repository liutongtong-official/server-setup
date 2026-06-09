#!/usr/bin/env bash
# Bootstrap a fresh server: shell config, dotfiles, ssh, toolchains.
# Idempotent — safe to re-run. Run all modules, or name a subset:
#   ./install.sh                 # everything
#   ./install.sh shell ssh       # only those modules
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Modules in execution order; each maps to modules/<name>.sh.
MODULES=(shell dotfiles ssh tools)

run_module() {
  local name="$1" file="$SCRIPT_DIR/modules/$name.sh"
  if [ ! -f "$file" ]; then
    err "unknown module: $name (valid: ${MODULES[*]})"
    return 1
  fi
  bash "$file"
}

main() {
  local selected=("$@")
  [ ${#selected[@]} -eq 0 ] && selected=("${MODULES[@]}")
  for name in "${selected[@]}"; do
    run_module "$name"
  done
  log "done. Restart your shell or 'source ~/.bashrc' to apply."
}

main "$@"
