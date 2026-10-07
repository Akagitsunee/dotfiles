#!/usr/bin/env bash
# Usage: ./uninstall.sh [component...]   (see ./uninstall.sh --list; default: all)
set -euo pipefail

# shellcheck source=lib/common.sh
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# Only removes symlinks that point into this repo; anything else is left alone.
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
      log "Removed $target_path"
      ;;
    *)
      log "Skipped $target_path (not managed by this repo)"
      ;;
  esac
}

# each_link callback: arguments are (target, source).
remove_row() { remove_link "$1"; }

remove_managed_links_in_dir() {
  local target_dir="$1"
  local target_path

  [ -d "$target_dir" ] || return 0

  shopt -s nullglob dotglob
  for target_path in "$target_dir"/*; do
    remove_link "$target_path"
  done
  shopt -u nullglob dotglob
}

remove_firefox_links() {
  local profile_dir

  profile_dir="$(firefox_profile_dir 2>/dev/null)" || return 0

  # chrome/ is a synced copy, not a symlink (see install.sh), so remove_link's
  # symlink check intentionally leaves it in place -- uninstalling shouldn't
  # delete the live ShyFox theme files out of the profile.
  remove_link "$profile_dir/chrome"
  remove_link "$profile_dir/user.js"
}

main() {
  local component

  parse_components "$@"

  for component in "${SELECTED[@]}"; do
    each_link "$component" remove_row
  done

  # The per-machine environment.zsh link is covered here; the file itself stays.
  if is_selected zsh; then
    remove_managed_links_in_dir "$CONFIG_DIR/zsh"
  fi
  if is_selected firefox; then
    remove_firefox_links
  fi

  log "Uninstall complete."
}

main "$@"
