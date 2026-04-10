#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

TARGETS=(
  "$HOME/.zshrc"
  "$HOME/.wezterm.lua"
  "$CONFIG_DIR/aerospace"
  "$CONFIG_DIR/ghostty"
  "$CONFIG_DIR/nvim"
  "$CONFIG_DIR/starship.toml"
  "$CONFIG_DIR/tmux/tmux.conf"
  "$CONFIG_DIR/tmux/onedark-theme.conf"
  "$CONFIG_DIR/tmux/nord-theme.conf"
  "$CONFIG_DIR/tmux-powerline"
  "$CONFIG_DIR/wezterm"
)

remove_link() {
  local target_path="$1"
  local resolved_target

  if [ ! -L "$target_path" ]; then
    return
  fi

  resolved_target="$(readlink "$target_path")"
  case "$resolved_target" in
    "$DOTFILES_DIR"/*)
      rm "$target_path"
      printf 'Removed %s\n' "$target_path"
      ;;
    *)
      printf 'Skipped %s (not managed by this repo)\n' "$target_path"
      ;;
  esac
}

main() {
  local target_path

  for target_path in "${TARGETS[@]}"; do
    remove_link "$target_path"
  done

  printf 'Uninstall complete.\n'
}

main "$@"
