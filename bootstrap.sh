#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-https://github.com/Akagitsunee/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-master}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$name" >&2
    exit 1
  fi
}

main() {
  require_command git

  if [ -d "$DOTFILES_DIR/.git" ]; then
    printf 'Updating %s\n' "$DOTFILES_DIR"
    git -C "$DOTFILES_DIR" fetch origin "$DOTFILES_BRANCH"
    git -C "$DOTFILES_DIR" checkout "$DOTFILES_BRANCH"
    git -C "$DOTFILES_DIR" pull --ff-only origin "$DOTFILES_BRANCH"
  else
    printf 'Cloning dotfiles into %s\n' "$DOTFILES_DIR"
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone --depth 1 --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
  fi

  exec "$DOTFILES_DIR/install.sh" "$@"
}

main "$@"
