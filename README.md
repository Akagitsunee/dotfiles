# dotfiles

Personal macOS/Linux shell and terminal setup with a single bootstrap command.

## Install

Fresh machine:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Akagitsunee/dotfiles/master/bootstrap.sh)"
```

That script will:

- clone this repo to `~/dev/dotfiles` if it is not there yet
- update it if it already exists
- run `install.sh`

If you already have the repo locally:

```bash
cd ~/dev/dotfiles
./install.sh
```

## What `install.sh` does

The installer is idempotent. Running it again updates plugin repos and refreshes links.

It will:

- back up existing files before replacing them
- install or update `oh-my-zsh` in `~/.oh-my-zsh`
- install or update the required Oh My Zsh custom plugins
- install required CLI tools when missing and a supported package manager is available
- install or update tmux plugins in `~/.config/tmux/plugins`
- symlink the configs from this repo into `~` and `~/.config`

Backups are stored in:

```bash
~/.dotfiles-backups/<timestamp>/
```

## Files

This repo only keeps personal config and custom files. Third-party dependencies are installed by the bootstrap scripts.

### Shell

- `zsh/.zprofile` -> `~/.zprofile`
- `zsh/.zshenv` -> `~/.zshenv`
- [`zsh/.zshrc`](zsh/.zshrc) -> `~/.config/zsh/.zshrc`
- zsh modules in [`zsh/`](zsh) -> `~/.config/zsh/`
- `oh-my-zsh` -> `~/.oh-my-zsh`
- Oh My Zsh custom plugins -> `~/.oh-my-zsh/custom/plugins/`
- CLI tools used by the shell config: `zoxide`, `eza`, `bat`, `fd`, `fzf`, `rg`
- Debian/Ubuntu package names are normalized when needed by linking `batcat` -> `bat` and `fdfind` -> `fd` in `~/.local/bin`

### Terminal and prompt

- [`wezterm/`](wezterm) -> `~/.config/wezterm/`
- [`wezterm/wezterm.lua`](wezterm/wezterm.lua) -> `~/.wezterm.lua`
- [`ghostty/`](ghostty) -> `~/.config/ghostty/`
- [`starship/starship.toml`](starship/starship.toml) -> `~/.config/starship.toml`

### Editor

- [`nvim/`](nvim) -> `~/.config/nvim/`

### Tmux

- [`tmux/tmux.conf`](tmux/tmux.conf) -> `~/.config/tmux/tmux.conf`
- [`tmux/onedark-theme.conf`](tmux/onedark-theme.conf) -> `~/.config/tmux/onedark-theme.conf`
- [`tmux/nord-theme.conf`](tmux/nord-theme.conf) -> `~/.config/tmux/nord-theme.conf`
- tmux plugins -> `~/.config/tmux/plugins/`
- [`tmux-powerline/`](tmux-powerline) -> `~/.config/tmux-powerline/`

### Window management

- [`aerospace/aerospace.toml`](aerospace/aerospace.toml) -> `~/.config/aerospace/aerospace.toml`

## Notes

- Existing files are moved out of the way before links are created.
- `stow.sh` and `unstow.sh` are compatibility wrappers around `install.sh` and `uninstall.sh`.
- The bootstrap command needs `git` and network access.
- `DOTFILES_DIR`, `DOTFILES_REPO_URL`, and `DOTFILES_BRANCH` can be set before running `bootstrap.sh`.

## Uninstall

```bash
cd ~/dev/dotfiles
./uninstall.sh
```

This removes symlinks created by the repo. It does not remove `~/.oh-my-zsh`, installed CLI tools, or downloaded tmux plugins.
