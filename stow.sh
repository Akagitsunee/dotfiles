#!/bin/bash
set -e

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_TARGET="$HOME/.config"

CONFIG_FOLDERS=(
    starship
    tmux-powerline
    nvim
    tmux
    wezterm
)

# === Symlink .zshrc ===
echo -e "${GREEN}→ Stowing zsh (.zshrc) into ~${RESET}"
stow --target="$HOME" zsh

# === Symlink .oh-my-zsh ===
echo -e "${GREEN}→ Symlinking .oh-my-zsh into ~${RESET}"
OH_MY_ZSH_SRC="$DOTFILES_DIR/.oh-my-zsh"
OH_MY_ZSH_DST="$HOME/.oh-my-zsh"

if [ -L "$OH_MY_ZSH_DST" ] || [ -d "$OH_MY_ZSH_DST" ]; then
    echo "  Removing existing $OH_MY_ZSH_DST"
    rm -rf "$OH_MY_ZSH_DST"
fi

echo "  Creating symlink $OH_MY_ZSH_DST -> $OH_MY_ZSH_SRC"
ln -s "$OH_MY_ZSH_SRC" "$OH_MY_ZSH_DST"

# === Symlink config folders ===
echo -e "${GREEN}→ Symlinking config folders into ~/.config/${RESET}"
mkdir -p "$CONFIG_TARGET"

for dir in "${CONFIG_FOLDERS[@]}"; do
    SRC="$DOTFILES_DIR/$dir"
    DST="$CONFIG_TARGET/$dir"

    if [ -L "$DST" ] || [ -d "$DST" ]; then
        echo "  Removing existing $DST"
        rm -rf "$DST"
    fi

    echo "  Creating symlink $DST -> $SRC"
    ln -s "$SRC" "$DST"
done

echo -e "${GREEN}✅ Done! Dotfiles are now linked.${RESET}"