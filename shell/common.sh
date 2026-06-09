# shellcheck shell=bash
# Shell config shared by bash and zsh. POSIX-compatible constructs only —
# anything bash-specific (mapfile/complete) or zsh-specific (compdef) lives in
# the respective rc file, not here.

# --- claude ---------------------------------------------------------------
claude-pull() {
  local dir
  for dir in ~/.claude/rules ~/.claude/skills; do
    echo "==> git pull in $dir"
    git -C "$dir" pull || return $?
  done
}

# --- git ------------------------------------------------------------------
alias glg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# gcd BRANCH — cd into the worktree checked out for BRANCH.
gcd() {
  local target
  target=$(git worktree list | grep "\[$1\]" | awk '{print $1}')
  if [ -n "$target" ]; then
    cd "$target"
  else
    echo "No worktree found for branch [$1]"
  fi
}

# --- go -------------------------------------------------------------------
export GOPATH="$HOME/.go"
export GOPROXY="https://mirrors.aliyun.com/goproxy,https://proxy.golang.org,direct"
export PATH="$HOME/.local/go/bin:$GOPATH/bin:$PATH"

# --- nvm ------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # loads nvm

# --- uv -------------------------------------------------------------------
[ -s "$HOME/.local/bin/env" ] && \. "$HOME/.local/bin/env"
export UV_INDEX_URL=http://mirrors.aliyun.com/pypi/simple/
