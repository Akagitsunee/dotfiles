#!/usr/bin/env bash
# Shared helpers and the link manifest for install.sh and uninstall.sh.
# Sourced, not executed. Stays compatible with macOS' bash 3.2.

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# `core` always runs first and owns no links.
COMPONENTS="core zsh nvim tmux terminal firefox"

# Format: "component|target|source (relative to the repo)"
LINKS=(
  "zsh|$HOME/.zprofile|zsh/.zprofile"
  "zsh|$HOME/.zshenv|zsh/.zshenv"
  "zsh|$CONFIG_DIR/starship.toml|starship/starship.toml"
  "nvim|$CONFIG_DIR/nvim|nvim"
  "tmux|$CONFIG_DIR/tmux/tmux.conf|tmux/tmux.conf"
  "tmux|$CONFIG_DIR/tmux/onedark-theme.conf|tmux/onedark-theme.conf"
  "tmux|$CONFIG_DIR/tmux/nord-theme.conf|tmux/nord-theme.conf"
  "tmux|$CONFIG_DIR/tmux-powerline|tmux-powerline"
  "terminal|$HOME/.wezterm.lua|wezterm/wezterm.lua"
  "terminal|$CONFIG_DIR/aerospace|aerospace"
  "terminal|$CONFIG_DIR/ghostty|ghostty"
  "terminal|$CONFIG_DIR/wezterm|wezterm"
)

SELECTED=()

log() { printf '%s\n' "$1"; }
warn() { printf '%s\n' "$1" >&2; }
die() {
  warn "$1"
  exit 1
}
has() { command -v "$1" >/dev/null 2>&1; }

# Fills SELECTED from the arguments (default: everything). `core` always comes first.
parse_components() {
  local component

  case "${1:-}" in
    --list)
      # shellcheck disable=SC2086 # word splitting of the component list is intended
      printf '%s\n' $COMPONENTS
      exit 0
      ;;
    -h | --help)
      printf 'Usage: %s [component...]\nComponents: %s\n' "$(basename "$0")" "$COMPONENTS"
      exit 0
      ;;
  esac

  # shellcheck disable=SC2086 # word splitting of the component list is intended
  [ "$#" -gt 0 ] || set -- $COMPONENTS

  SELECTED=(core)
  for component in "$@"; do
    case " $COMPONENTS " in
      *" $component "*) ;;
      *) die "Unknown component: $component (valid: $COMPONENTS)" ;;
    esac
    [ "$component" = core ] || SELECTED+=("$component")
  done
}

is_selected() {
  case " ${SELECTED[*]} " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

# Calls `callback target source_path` for every LINKS row of one component.
each_link() {
  local want="$1" callback="$2" row component target source

  for row in "${LINKS[@]}"; do
    IFS='|' read -r component target source <<<"$row"
    if [ "$component" = "$want" ]; then
      "$callback" "$target" "$DOTFILES_DIR/$source"
    fi
  done
}

# Prints the single Firefox *.default-release profile. Diagnostics go to stderr
# so callers capturing stdout never mistake a message for a path.
firefox_profile_dir() {
  local base_dir profile_dirs=()

  case "$(uname -s)" in
    Darwin) base_dir="$HOME/Library/Application Support/Firefox/Profiles" ;;
    *) base_dir="$HOME/.mozilla/firefox" ;;
  esac

  [ -d "$base_dir" ] || return 1

  shopt -s nullglob
  profile_dirs=("$base_dir"/*.default-release)
  shopt -u nullglob

  case "${#profile_dirs[@]}" in
    0)
      warn "Skipped Firefox config: no *.default-release profile found in $base_dir"
      return 1
      ;;
    1) printf '%s\n' "${profile_dirs[0]}" ;;
    *)
      warn "Skipped Firefox config: multiple *.default-release profiles found in $base_dir: ${profile_dirs[*]}"
      return 1
      ;;
  esac
}
