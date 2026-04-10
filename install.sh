#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backups}"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
BACKUP_USED=0

OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OH_MY_ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
TMUX_PLUGIN_DIR="$CONFIG_DIR/tmux/plugins"

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

HOME_LINKS=(
  ".zshrc zsh/.zshrc"
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

install_plugin_repos() {
  local entry repo_url target_path

  for entry in "$@"; do
    repo_url="${entry%% *}"
    target_path="${entry#* }"
    clone_or_update_repo "$repo_url" "$target_path"
  done
}

prepare_tmux_config_dir() {
  local tmux_config_dir="$CONFIG_DIR/tmux"

  if [ -L "$tmux_config_dir" ]; then
    backup_target "$tmux_config_dir"
  fi

  mkdir -p "$tmux_config_dir"
}

main() {
  local entry target_name source_relative

  require_command git
  sync_repo

  mkdir -p "$CONFIG_DIR"
  prepare_tmux_config_dir
  install_oh_my_zsh
  install_plugin_repos "${OH_MY_ZSH_PLUGIN_REPOS[@]}"
  install_plugin_repos "${TMUX_PLUGIN_REPOS[@]}"

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

  if [ "$BACKUP_USED" -eq 1 ]; then
    log "Existing files were moved to $BACKUP_DIR"
  fi

  log "Install complete."
}

main "$@"
