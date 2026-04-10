# dotfiles

Personal macOS/Linux shell and terminal setup with a single bootstrap command.

## Install

Fresh machine:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Akagitsunee/dotfiles/master/bootstrap.sh)"
```

That script will:

- clone this repo to `~/dotfiles` if it is not there yet
- update it if it already exists
- run `install.sh`

If you already have the repo locally:

```bash
cd ~/dotfiles
./install.sh
```

## What `install.sh` does

The installer is idempotent. Running it again updates plugin repos and refreshes links.

It will:

- back up existing files before replacing them
- install or update `oh-my-zsh` in `~/.oh-my-zsh`
- install or update the required Oh My Zsh custom plugins
- install or update tmux plugins in `~/.config/tmux/plugins`
- symlink the configs from this repo into `~` and `~/.config`

Backups are stored in:

```bash
~/.dotfiles-backups/<timestamp>/
```

## Files

This repo only keeps personal config and custom files. Third-party dependencies are installed by the bootstrap scripts.

### Shell

- [`zsh/.zshrc`](/Users/yano/dev/dotfiles/zsh/.zshrc) -> `~/.zshrc`
- `oh-my-zsh` -> `~/.oh-my-zsh`
- Oh My Zsh custom plugins -> `~/.oh-my-zsh/custom/plugins/`

### Terminal and prompt

- [`wezterm/`](/Users/yano/dev/dotfiles/wezterm) -> `~/.config/wezterm/`
- [`wezterm/wezterm.lua`](/Users/yano/dev/dotfiles/wezterm/wezterm.lua) -> `~/.wezterm.lua`
- [`ghostty/`](/Users/yano/dev/dotfiles/ghostty) -> `~/.config/ghostty/`
- [`starship/starship.toml`](/Users/yano/dev/dotfiles/starship/starship.toml) -> `~/.config/starship.toml`

### Editor

- [`nvim/`](/Users/yano/dev/dotfiles/nvim) -> `~/.config/nvim/`

### Tmux

- [`tmux/tmux.conf`](/Users/yano/dev/dotfiles/tmux/tmux.conf) -> `~/.config/tmux/tmux.conf`
- [`tmux/onedark-theme.conf`](/Users/yano/dev/dotfiles/tmux/onedark-theme.conf) -> `~/.config/tmux/onedark-theme.conf`
- [`tmux/nord-theme.conf`](/Users/yano/dev/dotfiles/tmux/nord-theme.conf) -> `~/.config/tmux/nord-theme.conf`
- tmux plugins -> `~/.config/tmux/plugins/`
- [`tmux-powerline/`](/Users/yano/dev/dotfiles/tmux-powerline) -> `~/.config/tmux-powerline/`

### Window management

- [`aerospace/aerospace.toml`](/Users/yano/dev/dotfiles/aerospace/aerospace.toml) -> `~/.config/aerospace/aerospace.toml`

## Notes

- Existing files are moved out of the way before links are created.
- `stow.sh` and `unstow.sh` are compatibility wrappers around `install.sh` and `uninstall.sh`.
- The bootstrap command needs `git` and network access.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

This removes symlinks created by the repo. It does not remove `~/.oh-my-zsh` or downloaded tmux plugins.
