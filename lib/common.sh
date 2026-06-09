# shellcheck shell=bash
# Shared helpers for the bootstrap scripts: logging, backup, idempotent symlink/append.
# Sourced by install.sh and every module; never executed directly.

set -euo pipefail

# Repo root, resolved from this file's location so modules work regardless of cwd.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_DIR

if [ -t 1 ]; then
  _C_RESET=$'\033[0m'; _C_BLUE=$'\033[34m'; _C_YELLOW=$'\033[33m'; _C_GREEN=$'\033[32m'; _C_RED=$'\033[31m'
else
  _C_RESET=''; _C_BLUE=''; _C_YELLOW=''; _C_GREEN=''; _C_RED=''
fi

log()  { printf '%s==>%s %s\n' "$_C_BLUE"   "$_C_RESET" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$_C_GREEN"  "$_C_RESET" "$*"; }
warn() { printf '%swarn%s %s\n' "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
err()  { printf '%s err%s %s\n' "$_C_RED"    "$_C_RESET" "$*" >&2; }

# backup_file PATH — move an existing regular file/dir aside with a timestamped suffix.
backup_file() {
  local path="$1"
  [ -e "$path" ] || return 0
  local backup
  backup="${path}.bak.$(date +%Y%m%d%H%M%S)"
  mv "$path" "$backup"
  warn "backed up existing $path -> $backup"
}

# symlink_safe SRC DST — link DST -> SRC idempotently, backing up a real file at DST.
symlink_safe() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "symlink up to date: $dst"
    return 0
  fi
  backup_file "$dst"  # no-op when nothing is there; backs up a real file/symlink
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  ok "linked $dst -> $src"
}

# append_once / prepend_once FILE MARKER LINE — write LINE to FILE, tagged with a
# trailing MARKER comment, only if MARKER is absent (so re-runs are no-ops).
# append adds at the end; prepend inserts at the top, for directives that must
# precede existing content (e.g. an ssh Include).
append_once()  { _insert_once append  "$@"; }
prepend_once() { _insert_once prepend "$@"; }

_insert_once() {
  local pos="$1" file="$2" marker="$3" line="$4"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -qF "$marker" "$file"; then
    ok "already configured: $file ($marker)"
    return 0
  fi
  if [ "$pos" = prepend ]; then
    { printf '%s # %s\n\n' "$line" "$marker"; cat "$file"; } >"$file.tmp"
    mv "$file.tmp" "$file"
    ok "prepended to $file ($marker)"
  else
    printf '\n%s # %s\n' "$line" "$marker" >>"$file"
    ok "appended to $file ($marker)"
  fi
}
