#!/bin/bash
set -e

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${GREEN}🚫 Unstowing dotfiles...${RESET}"
cd "$HOME/dotfiles"

# Unstow files into ~
echo -e "${GREEN}→ Unstowing zsh (.zshrc) and oh-my-zsh from ~${RESET}"
stow -D --target="$HOME" zsh || echo -e "${RED}Failed to unstow zsh${RESET}"
stow -D --target="$HOME" oh-my-zsh || echo -e "${RED}Failed to unstow oh-my-zsh${RESET}"

# Unstow config folders from ~/.config/
CONFIG_TARGET="$HOME/.config"
CONFIG_FOLDERS=(
    starship
    tmux-powerline
    nvim
    tmux
    wezterm
)

echo -e "${GREEN}→ Unstowing config folders from ~/.config/${RESET}"
for dir in "${CONFIG_FOLDERS[@]}"; do
    echo -e "  - Unstowing $dir"
    stow -D --target="$CONFIG_TARGET" "$dir" || echo -e "${RED}Failed to unstow $dir${RESET}"
done

echo -e "${GREEN}✅ Done! Dotfiles have been unstowed.${RESET}"

