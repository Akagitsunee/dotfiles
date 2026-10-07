#!/usr/bin/env bash
# Usage: ./install.sh [component...]   (see ./install.sh --list; default: all)
set -euo pipefail

# shellcheck source=lib/common.sh
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backups}"
BACKUP_DIR="$BACKUP_ROOT/$(date +"%Y%m%d-%H%M%S")"
BACKUP_USED=0
PACKAGE_MANAGER=""

OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OH_MY_ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
TMUX_PLUGIN_DIR="$CONFIG_DIR/tmux/plugins"
NVM_DIR="${NVM_DIR:-$DATA_DIR/nvm}"

OH_MY_ZSH_PLUGIN_REPOS=(
  "https://github.com/zsh-users/zsh-autosuggestions.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-completions.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-completions"
  "https://github.com/zsh-users/zsh-syntax-highlighting.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  "https://github.com/bobthecow/git-flow-completion.git $OH_MY_ZSH_CUSTOM_DIR/plugins/git-flow-completion"
  "https://github.com/b4b4r07/enhancd.git $OH_MY_ZSH_CUSTOM_DIR/plugins/enhancd"
  "https://github.com/supercrabtree/k.git $OH_MY_ZSH_CUSTOM_DIR/plugins/k"
)

TMUX_PLUGIN_REPOS=(
  "https://github.com/tmux-plugins/tpm.git $TMUX_PLUGIN_DIR/tpm"
  "https://github.com/christoomey/vim-tmux-navigator.git $TMUX_PLUGIN_DIR/vim-tmux-navigator"
  "https://github.com/tmux-plugins/tmux-resurrect.git $TMUX_PLUGIN_DIR/tmux-resurrect"
  "https://github.com/tmux-plugins/tmux-continuum.git $TMUX_PLUGIN_DIR/tmux-continuum"
  "https://github.com/erikw/tmux-powerline.git $TMUX_PLUGIN_DIR/tmux-powerline"
)

# Format: "component command brew_package pacman_package apt_package dnf_package"
CLI_TOOL_PACKAGES=(
  "zsh zoxide zoxide zoxide zoxide zoxide"
  "zsh eza eza eza eza eza"
  "zsh bat bat bat bat bat"
  "zsh fd fd fd fd-find fd-find"
  "zsh fzf fzf fzf fzf fzf"
  "zsh rg ripgrep ripgrep ripgrep ripgrep"
  "tmux tmux tmux tmux tmux tmux"
  "nvim nvim neovim neovim neovim neovim"
  # nvim-treesitter's `main` branch (see nvim/lua/plugins/core/treesitter.lua)
  # shells out to the tree-sitter CLI to install/update parsers.
  "nvim tree-sitter tree-sitter-cli tree-sitter-cli tree-sitter-cli tree-sitter-cli"
)

# Homebrew-only extras. Format: "component|name|brew install arguments"
BREW_EXTRAS=(
  "zsh|starship|starship"
  "terminal|borders|FelixKratz/formulae/borders"
  "terminal|ghostty|--cask ghostty"
  "terminal|font-jetbrains-mono-nerd-font|--cask font-jetbrains-mono-nerd-font"
)

# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------

backup_target() {
  local target="$1"
  local relative backup_path

  relative="${target#"$HOME"/}"
  if [ "$relative" = "$target" ]; then
    relative="$(basename "$target")"
  fi

  backup_path="$BACKUP_DIR/$relative"
  mkdir -p "$(dirname "$backup_path")"
  mv "$target" "$backup_path"
  BACKUP_USED=1

  log "Backed up $target -> $backup_path"
}

link_target() {
  local source_path="$1"
  local target_path="$2"

  if [ ! -e "$source_path" ] && [ ! -L "$source_path" ]; then
    log "Skipped missing source: $source_path"
    return
  fi

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    log "Already linked: $target_path"
    return
  fi

  if [ -L "$target_path" ] || [ -e "$target_path" ]; then
    backup_target "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  log "Linked $target_path -> $source_path"
}

# each_link callback: arguments are (target, source), the reverse of link_target.
link_row() { link_target "$2" "$1"; }
link_component() { each_link "$1" link_row; }

sync_dir_target() {
  local source_dir="$1"
  local target_dir="$2"

  if [ ! -d "$source_dir" ]; then
    log "Skipped missing source: $source_dir"
    return
  fi

  if [ -L "$target_dir" ] || { [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; }; then
    backup_target "$target_dir"
  fi

  mkdir -p "$target_dir"

  if has rsync; then
    rsync -a --delete "$source_dir"/ "$target_dir"/
  else
    rm -rf "$target_dir"
    cp -R "$source_dir" "$target_dir"
  fi

  log "Synced $target_dir <- $source_dir"
}

clone_or_update_repo() {
  local repo_url="$1"
  local target_path="$2"

  if [ -d "$target_path/.git" ]; then
    log "Updating $(basename "$target_path")"
    git -C "$target_path" pull --ff-only || log "Update skipped for $target_path"
    return
  fi

  if [ -e "$target_path" ]; then
    backup_target "$target_path"
  fi

  mkdir -p "$(dirname "$target_path")"
  log "Cloning $repo_url -> $target_path"
  git clone --depth 1 "$repo_url" "$target_path"
}

# Entries are "repo_url target_path".
install_plugin_repos() {
  local entry

  for entry in "$@"; do
    clone_or_update_repo "${entry%% *}" "${entry#* }"
  done
}

# Creates an empty, never-versioned, machine-specific file if it doesn't exist.
ensure_local_file() {
  local path="$1"

  [ -e "$path" ] && return 0

  printf '%s\n' \
    "# Machine-specific zsh config (work, private, ...). Not versioned: see .gitignore." \
    >"$path"
  log "Created $path"
}

# ---------------------------------------------------------------------------
# core: repo sync, CLI tools, Homebrew extras
# ---------------------------------------------------------------------------

sync_repo() {
  [ -d "$DOTFILES_DIR/.git" ] || return 0
  # bootstrap.sh has just pulled.
  [ -z "${DOTFILES_SKIP_PULL:-}" ] || return 0

  log "Updating dotfiles repo"
  git -C "$DOTFILES_DIR" pull --ff-only || log "Repo update skipped due to local changes or network failure."
}

detect_package_manager() {
  local pm

  for pm in brew pacman apt-get dnf; do
    if has "$pm"; then
      printf '%s\n' "$pm"
      return
    fi
  done
}

# Debian/Ubuntu ship bat and fd as batcat/fdfind.
ensure_compat_command() {
  local command_name="$1"
  local fallback_name="$2"

  has "$command_name" && return 0
  has "$fallback_name" || return 0

  link_target "$(command -v "$fallback_name")" "$HOME/.local/bin/$command_name"
}

ensure_cli_tools() {
  local entry component command_name brew_pkg pacman_pkg apt_pkg dnf_pkg package_name
  local missing=()

  for entry in "${CLI_TOOL_PACKAGES[@]}"; do
    read -r component command_name brew_pkg pacman_pkg apt_pkg dnf_pkg <<<"$entry"
    is_selected "$component" || continue

    if has "$command_name"; then
      log "Already installed: $command_name"
      continue
    fi

    case "$PACKAGE_MANAGER" in
      brew) package_name="$brew_pkg" ;;
      pacman) package_name="$pacman_pkg" ;;
      apt-get) package_name="$apt_pkg" ;;
      dnf) package_name="$dnf_pkg" ;;
      *)
        log "Missing $command_name and no supported package manager found."
        continue
        ;;
    esac
    missing+=("$package_name")
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    log "Installing CLI tools with $PACKAGE_MANAGER: ${missing[*]}"
    case "$PACKAGE_MANAGER" in
      brew) brew install "${missing[@]}" ;;
      pacman) sudo pacman -S --needed "${missing[@]}" ;;
      apt-get)
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}"
        ;;
      dnf) sudo dnf install -y "${missing[@]}" ;;
    esac
  fi

  if is_selected zsh; then
    ensure_compat_command bat batcat
    ensure_compat_command fd fdfind
  fi
}

brew_extra_installed() {
  case "$1" in
    ghostty) has ghostty || [ -d "/Applications/Ghostty.app" ] ;;
    font-*) brew list --cask "$1" >/dev/null 2>&1 ;;
    *) has "$1" ;;
  esac
}

ensure_brew_extras() {
  local entry component name brew_args

  if [ "$PACKAGE_MANAGER" != "brew" ]; then
    if is_selected zsh || is_selected terminal; then
      log "Homebrew not detected. Install ghostty, starship, and borders manually if needed."
    fi
    return
  fi

  for entry in "${BREW_EXTRAS[@]}"; do
    IFS='|' read -r component name brew_args <<<"$entry"
    is_selected "$component" || continue

    if brew_extra_installed "$name"; then
      log "Already installed: $name"
    else
      log "Installing $name with Homebrew"
      # shellcheck disable=SC2086 # brew_args holds several arguments on purpose
      brew install $brew_args
    fi
  done
}

install_core() {
  require_git

  sync_repo
  PACKAGE_MANAGER="$(detect_package_manager)"
  ensure_cli_tools
  ensure_brew_extras
}

require_git() {
  has git || die "Missing required command: git"
}

# ---------------------------------------------------------------------------
# zsh: oh-my-zsh, nvm, plugins, starship, config files
# ---------------------------------------------------------------------------

link_zsh_config_files() {
  local source_path name

  shopt -s nullglob
  for source_path in "$DOTFILES_DIR"/zsh/* "$DOTFILES_DIR"/zsh/.[!.]*; do
    [ -f "$source_path" ] || continue

    name="$(basename "$source_path")"
    case "$name" in
      # .zprofile and .zshenv are linked into $HOME via LINKS.
      .zprofile | .zshenv | .DS_Store) continue ;;
    esac

    link_target "$source_path" "$CONFIG_DIR/zsh/$name"
  done
  shopt -u nullglob
}

install_zsh() {
  mkdir -p "$CONFIG_DIR/zsh" "$CACHE_DIR/zsh" "$STATE_DIR/zsh"

  clone_or_update_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_DIR"
  clone_or_update_repo "https://github.com/nvm-sh/nvm.git" "$NVM_DIR"
  install_plugin_repos "${OH_MY_ZSH_PLUGIN_REPOS[@]}"

  ensure_local_file "$DOTFILES_DIR/zsh/environment.zsh"
  link_component zsh
  link_zsh_config_files
}

# ---------------------------------------------------------------------------
# nvim
# ---------------------------------------------------------------------------

install_nvim() {
  link_component nvim
}

# ---------------------------------------------------------------------------
# tmux
# ---------------------------------------------------------------------------

install_tmux() {
  # tmux/ must be a real directory (plugins live inside it), not a symlink.
  if [ -L "$CONFIG_DIR/tmux" ]; then
    backup_target "$CONFIG_DIR/tmux"
  fi
  mkdir -p "$CONFIG_DIR/tmux"

  install_plugin_repos "${TMUX_PLUGIN_REPOS[@]}"
  link_component tmux
}

# ---------------------------------------------------------------------------
# terminal: ghostty, wezterm, aerospace
# ---------------------------------------------------------------------------

install_terminal() {
  link_component terminal
}

# ---------------------------------------------------------------------------
# firefox
# ---------------------------------------------------------------------------

install_firefox() {
  local profile_dir

  profile_dir="$(firefox_profile_dir)" || return 0

  # chrome/ is synced (copied), not symlinked: Firefox refuses to apply
  # userContent.css's @-moz-document rule targeting Sidebery's moz-extension://
  # sidebar page when the source resolves outside the profile directory via a
  # symlink -- confirmed by reproducing it twice. user.js is unaffected (it's
  # just a prefs file, not part of that content-CSS-into-extension-page path).
  sync_dir_target "$DOTFILES_DIR/firefox/chrome" "$profile_dir/chrome"
  link_target "$DOTFILES_DIR/firefox/user.js" "$profile_dir/user.js"
}

# ---------------------------------------------------------------------------

main() {
  local component

  parse_components "$@"

  for component in "${SELECTED[@]}"; do
    "install_$component"
  done

  if [ "$BACKUP_USED" -eq 1 ]; then
    log "Existing files were moved to $BACKUP_DIR"
  fi

  log "Install complete."
}

main "$@"
