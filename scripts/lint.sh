#!/usr/bin/env bash
# Lint the repo's shell scripts with shellcheck. Single source of truth for the
# lint fileset, shared by the pre-commit hook and CI.
#
# zsh files are excluded: shellcheck has no zsh parser and would emit false
# positives on zsh-only syntax.
#
# Kept compatible with bash 3.2 (macOS default) — no mapfile/associative arrays.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Auto-discover bash scripts: a file is linted iff its first two lines carry a
# bash/sh shebang or a `shellcheck shell=` directive. zsh files carry neither, so
# they are excluded by the same rule (shellcheck has no zsh parser anyway).
files=()
while IFS= read -r f; do
  files+=("$f")
done < <(
  git ls-files | while read -r g; do
    if head -n2 "$g" 2>/dev/null | grep -qE '^#!.*\b(bash|sh)\b|shellcheck shell=(bash|sh)'; then
      printf '%s\n' "$g"
    fi
  done
)

if [ ${#files[@]} -eq 0 ]; then
  echo "no shell scripts found to lint"
  exit 0
fi

printf 'shellcheck %s file(s):\n' "${#files[@]}"
printf '  %s\n' "${files[@]}"
shellcheck -x "${files[@]}"
echo "shellcheck: clean"
