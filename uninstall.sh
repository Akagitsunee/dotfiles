#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

TARGETS=(
  "$HOME/.zprofile"
  "$HOME/.zshenv"
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

remove_managed_links_in_dir() {
  local target_dir="$1"
  local target_path

  [ -d "$target_dir" ] || return

  shopt -s nullglob dotglob
  for target_path in "$target_dir"/*; do
    remove_link "$target_path"
  done
  shopt -u nullglob dotglob
}

firefox_profile_dir() {
  local base_dir profile_dirs=()

  case "$(uname -s)" in
    Darwin) base_dir="$HOME/Library/Application Support/Firefox/Profiles" ;;
    *) base_dir="$HOME/.mozilla/firefox" ;;
  esac

  [ -d "$base_dir" ] || return

  shopt -s nullglob
  profile_dirs=("$base_dir"/*.default-release)
  shopt -u nullglob

  [ "${#profile_dirs[@]}" -eq 1 ] || return

  printf '%s\n' "${profile_dirs[0]}"
}

remove_firefox_links() {
  local profile_dir

  profile_dir="$(firefox_profile_dir)"
  [ -n "$profile_dir" ] || return

  # chrome/ is a synced copy, not a symlink (see install.sh), so remove_link's
  # symlink check intentionally leaves it in place -- uninstalling shouldn't
  # delete the live ShyFox theme files out of the profile.
  remove_link "$profile_dir/chrome"
  remove_link "$profile_dir/user.js"
}

main() {
  local target_path

  for target_path in "${TARGETS[@]}"; do
    remove_link "$target_path"
  done

  remove_managed_links_in_dir "$CONFIG_DIR/zsh"
  remove_firefox_links

  printf 'Uninstall complete.\n'
}

main "$@"
