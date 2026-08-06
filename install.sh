#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backups}"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
BACKUP_USED=0

OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OH_MY_ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
TMUX_PLUGIN_DIR="$CONFIG_DIR/tmux/plugins"
NVM_DIR="${NVM_DIR:-$DATA_DIR/nvm}"

OH_MY_ZSH_PLUGIN_REPOS=(
  "https://github.com/zsh-users/zsh-autosuggestions.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-completions.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-completions"
  "https://github.com/zsh-users/zsh-syntax-highlighting.git $OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  "https://github.com/unixorn/git-flow-completion.git $OH_MY_ZSH_CUSTOM_DIR/plugins/git-flow-completion"
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

# Format: "command brew_package pacman_package apt_package dnf_package"
CLI_TOOL_PACKAGES=(
  "zoxide zoxide zoxide zoxide zoxide"
  "eza eza eza eza eza"
  "bat bat bat bat bat"
  "fd fd fd fd-find fd-find"
  "fzf fzf fzf fzf fzf"
  "rg ripgrep ripgrep ripgrep ripgrep"
  "tmux tmux tmux tmux tmux"
  "nvim neovim neovim neovim neovim"
)

HOME_LINKS=(
  ".zprofile zsh/.zprofile"
  ".zshenv zsh/.zshenv"
  ".wezterm.lua wezterm/wezterm.lua"
)

CONFIG_DIR_LINKS=(
  "aerospace aerospace"
  "ghostty ghostty"
  "nvim nvim"
  "tmux-powerline tmux-powerline"
  "wezterm wezterm"
)

CONFIG_FILE_LINKS=(
  "starship.toml starship/starship.toml"
  "tmux/tmux.conf tmux/tmux.conf"
  "tmux/onedark-theme.conf tmux/onedark-theme.conf"
  "tmux/nord-theme.conf tmux/nord-theme.conf"
)

log() {
  printf '%s\n' "$1"
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    log "Missing required command: $name"
    exit 1
  fi
}

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

sync_repo() {
  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    return
  fi

  log "Updating dotfiles repo"
  git -C "$DOTFILES_DIR" pull --ff-only || log "Repo update skipped due to local changes or network failure."
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

install_oh_my_zsh() {
  clone_or_update_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_DIR"
}

install_nvm() {
  clone_or_update_repo "https://github.com/nvm-sh/nvm.git" "$NVM_DIR"
}

install_plugin_repos() {
  local entry repo_url target_path

  for entry in "$@"; do
    repo_url="${entry%% *}"
    target_path="${entry#* }"
    clone_or_update_repo "$repo_url" "$target_path"
  done
}

detect_package_manager() {
  if command -v brew >/dev/null 2>&1; then
    printf 'brew\n'
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    printf 'pacman\n'
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    printf 'apt-get\n'
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    printf 'dnf\n'
    return
  fi
}

add_unique_package() {
  local package="$1"
  local existing

  for existing in "${MISSING_PACKAGES[@]}"; do
    if [ "$existing" = "$package" ]; then
      return
    fi
  done

  MISSING_PACKAGES+=("$package")
}

ensure_compat_command() {
  local command_name="$1"
  local fallback_name="$2"
  local fallback_path target_path

  if command -v "$command_name" >/dev/null 2>&1; then
    return
  fi

  if ! command -v "$fallback_name" >/dev/null 2>&1; then
    return
  fi

  fallback_path="$(command -v "$fallback_name")"
  target_path="$HOME/.local/bin/$command_name"
  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$fallback_path" ]; then
    log "Already linked: $target_path"
    return
  fi

  if [ -L "$target_path" ] || [ -e "$target_path" ]; then
    backup_target "$target_path"
  fi

  ln -s "$fallback_path" "$target_path"
  log "Linked $target_path -> $fallback_path"
}

ensure_cli_tools() {
  local package_manager entry command_name brew_pkg pacman_pkg apt_pkg dnf_pkg package_name
  MISSING_PACKAGES=()

  package_manager="$(detect_package_manager || true)"

  for entry in "${CLI_TOOL_PACKAGES[@]}"; do
    read -r command_name brew_pkg pacman_pkg apt_pkg dnf_pkg <<<"$entry"

    if command -v "$command_name" >/dev/null 2>&1; then
      log "Already installed: $command_name"
      continue
    fi

    case "$package_manager" in
      brew) package_name="$brew_pkg" ;;
      pacman) package_name="$pacman_pkg" ;;
      apt-get) package_name="$apt_pkg" ;;
      dnf) package_name="$dnf_pkg" ;;
      *) package_name="" ;;
    esac

    if [ -n "$package_name" ]; then
      add_unique_package "$package_name"
    else
      log "Missing $command_name and no supported package manager found."
    fi
  done

  if [ "${#MISSING_PACKAGES[@]}" -gt 0 ]; then
    case "$package_manager" in
      brew)
        log "Installing CLI tools with Homebrew: ${MISSING_PACKAGES[*]}"
        brew install "${MISSING_PACKAGES[@]}"
        ;;
      pacman)
        log "Installing CLI tools with pacman: ${MISSING_PACKAGES[*]}"
        sudo pacman -S --needed "${MISSING_PACKAGES[@]}"
        ;;
      apt-get)
        log "Installing CLI tools with apt-get: ${MISSING_PACKAGES[*]}"
        sudo apt-get update
        sudo apt-get install -y "${MISSING_PACKAGES[@]}"
        ;;
      dnf)
        log "Installing CLI tools with dnf: ${MISSING_PACKAGES[*]}"
        sudo dnf install -y "${MISSING_PACKAGES[@]}"
        ;;
    esac
  fi

  ensure_compat_command bat batcat
  ensure_compat_command fd fdfind
  unset MISSING_PACKAGES
}

ensure_brew_extras() {
  if [ "$(detect_package_manager || true)" != "brew" ]; then
    log "Homebrew not detected. Install ghostty, starship, and borders manually if needed."
    return
  fi

  if command -v starship >/dev/null 2>&1; then
    log "Already installed: starship"
  else
    log "Installing starship with Homebrew"
    brew install starship
  fi

  if command -v borders >/dev/null 2>&1; then
    log "Already installed: borders"
  else
    log "Installing borders with Homebrew"
    brew tap FelixKratz/formulae
    brew install borders
  fi

  if command -v ghostty >/dev/null 2>&1 || [ -d "/Applications/Ghostty.app" ]; then
    log "Already installed: ghostty"
  else
    log "Installing ghostty with Homebrew"
    brew install --cask ghostty
  fi

  if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
    log "Already installed: font-jetbrains-mono-nerd-font"
  else
    log "Installing JetBrainsMono Nerd Font with Homebrew"
    brew install --cask font-jetbrains-mono-nerd-font
  fi
}

prepare_tmux_config_dir() {
  local tmux_config_dir="$CONFIG_DIR/tmux"

  if [ -L "$tmux_config_dir" ]; then
    backup_target "$tmux_config_dir"
  fi

  mkdir -p "$tmux_config_dir"
}

link_zsh_config_files() {
  local source_path basename

  shopt -s nullglob
  for source_path in "$DOTFILES_DIR"/zsh/* "$DOTFILES_DIR"/zsh/.[!.]*; do
    [ -f "$source_path" ] || continue

    basename="$(basename "$source_path")"
    case "$basename" in
      .zprofile|.zshenv|.DS_Store)
        continue
        ;;
    esac

    link_target "$source_path" "$CONFIG_DIR/zsh/$basename"
  done
  shopt -u nullglob
}

main() {
  local entry target_name source_relative

  require_command git
  sync_repo

  mkdir -p "$CONFIG_DIR/zsh" "$CACHE_DIR/zsh" "$STATE_DIR/zsh" "$DATA_DIR"
  prepare_tmux_config_dir
  install_oh_my_zsh
  install_nvm
  install_plugin_repos "${OH_MY_ZSH_PLUGIN_REPOS[@]}"
  install_plugin_repos "${TMUX_PLUGIN_REPOS[@]}"
  ensure_cli_tools
  ensure_brew_extras

  for entry in "${HOME_LINKS[@]}"; do
    target_name="${entry%% *}"
    source_relative="${entry#* }"
    link_target "$DOTFILES_DIR/$source_relative" "$HOME/$target_name"
  done

  for entry in "${CONFIG_DIR_LINKS[@]}"; do
    target_name="${entry%% *}"
    source_relative="${entry#* }"
    link_target "$DOTFILES_DIR/$source_relative" "$CONFIG_DIR/$target_name"
  done

  for entry in "${CONFIG_FILE_LINKS[@]}"; do
    target_name="${entry%% *}"
    source_relative="${entry#* }"
    link_target "$DOTFILES_DIR/$source_relative" "$CONFIG_DIR/$target_name"
  done

  link_zsh_config_files

  if [ "$BACKUP_USED" -eq 1 ]; then
    log "Existing files were moved to $BACKUP_DIR"
  fi

  log "Install complete."
}

main "$@"
