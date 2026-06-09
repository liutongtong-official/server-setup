# shellcheck shell=bash
# Install the language toolchains the shell config expects: go, nvm, uv.
# Everything lands under $HOME (no sudo, no global package scope); each step
# is skipped when the tool is already present.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# GO_VERSION pins a version (e.g. 1.26.1); empty means fetch the latest stable.
GO_VERSION="${GO_VERSION:-}"
# NVM_VERSION pins a git tag (e.g. v0.40.1); empty resolves the latest release.
NVM_VERSION="${NVM_VERSION:-}"

install_go() {
  if command -v go >/dev/null 2>&1; then
    ok "go already installed: $(go version)"
    return 0
  fi
  if [ -z "$GO_VERSION" ]; then
    # `|| true` so a failed fetch falls through to the guard below instead of
    # aborting via `set -e` before the diagnostic can print.
    GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1 | sed 's/^go//') || true
    [ -n "$GO_VERSION" ] || { err "could not resolve latest go version"; return 1; }
  fi
  local os arch
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$(uname -m)" in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) err "unsupported arch for go: $(uname -m)"; return 1 ;;
  esac
  local tarball="go${GO_VERSION}.${os}-${arch}.tar.gz"
  log "installing go ${GO_VERSION} -> $HOME/.local/go"
  curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
  rm -rf "$HOME/.local/go"
  mkdir -p "$HOME/.local"
  tar -C "$HOME/.local" -xzf "/tmp/${tarball}"
  rm -f "/tmp/${tarball}"
  ok "installed $("$HOME/.local/go/bin/go" version)"
}

install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    ok "nvm already installed: $HOME/.nvm"
    return 0
  fi
  if [ -z "$NVM_VERSION" ]; then
    # Resolve the latest tag from the release redirect rather than the API, which
    # is rate-limited to 60 req/h per IP (fails behind shared NATs / in CI).
    # `|| true` so a failed fetch falls through to the guard instead of aborting
    # via `set -e` before the diagnostic can print.
    local latest_url
    latest_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/nvm-sh/nvm/releases/latest") || true
    NVM_VERSION="${latest_url##*/}"
    [ -n "$NVM_VERSION" ] || { err "could not resolve latest nvm version"; return 1; }
  fi
  log "installing nvm ${NVM_VERSION} -> $HOME/.nvm"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

install_uv() {
  if command -v uv >/dev/null 2>&1 || [ -x "$HOME/.local/bin/uv" ]; then
    ok "uv already installed"
    return 0
  fi
  log "installing uv -> $HOME/.local/bin"
  curl -fsSL https://astral.sh/uv/install.sh | sh
}

log "installing toolchains"
install_go
install_nvm
install_uv
