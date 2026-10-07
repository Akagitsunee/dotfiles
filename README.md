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

## Installing only parts

Both scripts accept component names (`core zsh nvim tmux terminal firefox`); without arguments everything is handled. `core` always runs first.

```bash
./install.sh --list
./install.sh nvim tmux
./uninstall.sh tmux
```

Links live in one table, `LINKS` in [`lib/common.sh`](lib/common.sh), shared by both scripts.

## Machine-specific config

`zsh/environment.zsh` holds per-machine settings (work, private, ...). It is git-ignored; `install.sh` creates an empty stub if missing and links it to `~/.config/zsh/environment.zsh`, and `.zshrc` sources it when present. `uninstall.sh` removes the link but keeps the file.

## What `install.sh` does

The installer is idempotent. Running it again updates plugin repos and refreshes links.

It will:

- back up existing files before replacing them
- install or update `oh-my-zsh` in `~/.oh-my-zsh`
- install or update `nvm` (cloned from GitHub, not Homebrew — see [Node](#node) below)
- install or update the required Oh My Zsh custom plugins
- install required CLI tools when missing and a supported package manager is available
- on macOS with Homebrew, install `ghostty`, `starship`, `borders`, and the JetBrainsMono Nerd Font if missing
- install or update tmux plugins in `~/.config/tmux/plugins`
- sync the ShyFox theme into the Firefox profile and link `user.js` (see [Browser](#browser))
- create the git-ignored `zsh/environment.zsh` stub if it is missing (see [Machine-specific config](#machine-specific-config))
- symlink the configs from this repo into `~` and `~/.config`
- only handle the components you name, if you name any (see [Installing only parts](#installing-only-parts))

### Prerequisites not automated

- **Homebrew itself** — `install.sh` uses it to install other tools but does not install it. On a fresh Mac, install it first from [brew.sh](https://brew.sh).
- **uv** — the `python`/`pip` aliases route through it, so they fail without it; install it from [docs.astral.sh/uv](https://docs.astral.sh/uv/).
- **AeroSpace** — window manager the `aerospace/` config targets; install manually (`brew install --cask nikitabobko/tap/aerospace`).
- **Fonts for `wezterm/`** — if you go back to using wezterm, its fallback list expects several Nerd Fonts beyond the JetBrainsMono one `install.sh` installs for ghostty (FiraCode, CaskaydiaCove, SauceCodePro, CommitMono, RobotoMono); install what you need manually.

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
- `.zshrc` pins `SSH_AUTH_SOCK` to the static socket `~/.ssh/ssh-agent.sock`, starts an agent there if none answers, and loads keys from the macOS keychain; `tmux.conf` points tmux at the same socket so every pane shares one agent
- `MANPAGER` pipes through `col -bx` before `bat` so man pages render without backspace overstrike; `~/.local/bin` is prepended last in `.zshenv`, so it wins over the other PATH entries
- Debian/Ubuntu package names are normalized when needed by linking `batcat` -> `bat` and `fdfind` -> `fd` in `~/.local/bin`

#### Aliases

[`zsh/aliases.zsh`](zsh/aliases.zsh) deliberately overrides several commands:

- `ls` / `tree` -> `eza`, `grep` -> `rg`, `vim` -> `nvim`
- `npm` -> `pnpm`, `npx` -> `pnpm dlx`
- `python` / `python3` -> `uv run python`, `pip` / `pip3` -> `uv pip`
- `stim` -> `caffeinate -dimsu` (macOS: keep display, system and disks awake and simulate user activity)

#### Node

Node itself is intentionally **not** installed by this repo. `install.sh` clones `nvm` from GitHub into `~/.local/share/nvm` (not the Homebrew formula, which nvm's own docs advise against) and `.zshenv`/`.zshrc` load it from there. Install whatever Node versions you need with `nvm install <version>` after running the installer.

`npm` ships with whichever Node version `nvm` installs, so there's nothing separate to set up. For `pnpm`, prefer `corepack enable` (built into Node) over a global Homebrew/npm install — it keeps the pnpm version scoped per project instead of one global version drifting out of sync.

### Terminal and prompt

- [`ghostty/`](ghostty) -> `~/.config/ghostty/` — the terminal actually in use; `install.sh` installs it via Homebrew cask on macOS if missing
- [`starship/starship.toml`](starship/starship.toml) -> `~/.config/starship.toml` — auto-installed via Homebrew on macOS if missing
- [`wezterm/`](wezterm) -> `~/.config/wezterm/`
- [`wezterm/wezterm.lua`](wezterm/wezterm.lua) -> `~/.wezterm.lua`
  - kept for reference but no longer the daily driver; config is symlinked but not auto-installed

### Editor

- [`nvim/`](nvim) -> `~/.config/nvim/`
- `nvim` itself is auto-installed (as `neovim`) by `install.sh` if missing
- everything Mason installs is a prebuilt binary or an npm package (Node comes from nvm), so no extra system prerequisite is installed for it
- Go tooling is gated on `go`: `gopls`, `goimports`, `gofumpt`, `golangci-lint` and `delve` are only installed by Mason when `go` is on `$PATH`, so nvim works on a fresh machine without the Go SDK (see [`nvim/README.md`](nvim/README.md#requirements))
- not yet automated: the build toolchain some plugins need (`make`, a C compiler, and `go` if you want Go support; `blink.cmp`/`blink.pairs` ship prebuilt binaries, so `cargo` is no longer needed) — see [`nvim/README.md`](nvim/README.md#requirements)

### Tmux

- [`tmux/tmux.conf`](tmux/tmux.conf) -> `~/.config/tmux/tmux.conf`
- [`tmux/onedark-theme.conf`](tmux/onedark-theme.conf) -> `~/.config/tmux/onedark-theme.conf`
- [`tmux/nord-theme.conf`](tmux/nord-theme.conf) -> `~/.config/tmux/nord-theme.conf`
- `tmux` itself is auto-installed by `install.sh` if missing (ghostty launches straight into it, so this matters)
- tmux plugins -> `~/.config/tmux/plugins/`
- [`tmux/tmux-cheatsheet.md`](tmux/tmux-cheatsheet.md) lists the key bindings (prefix `Ctrl+Space`, `Ctrl+h/j/k/l` navigation shared with nvim)
- `tmux.conf` enables `focus-events` and `extended-keys` and advertises Ghostty's features (true colour, hyperlinks), so nvim's focus autocmds and modified keys work inside tmux; `ghostty/config` sets `macos-option-as-alt = true`
- [`tmux-powerline/`](tmux-powerline) -> `~/.config/tmux-powerline/`

### Browser

- [`firefox/chrome/`](firefox/chrome) is **synced (copied), not symlinked**, into `<Firefox profile>/chrome/` — the ShyFox userChrome theme (auto-hiding toolbars/urlbar, plus a Sidebery skin). Firefox refuses to apply `userContent.css`'s `@-moz-document` rule targeting Sidebery's `moz-extension://` sidebar page when the source resolves outside the profile directory via a symlink (confirmed by reproducing it twice); a real copy inside the profile works fine. This means editing the theme requires re-running `install.sh` to push changes into the live profile — it won't reflect instantly like a symlink would.
- [`firefox/user.js`](firefox/user.js) -> `<Firefox profile>/user.js` — still a normal symlink, since it's just a prefs file and unaffected by the above restriction. Sets `toolkit.legacyUserProfileCustomizations.stylesheets` (required for the theme to load at all) and `sidebar.revamp=false` (reverts Firefox 154+'s new native sidebar default, which otherwise breaks Sidebery's and ShyFox's sidebar layout).
- the profile path is resolved at install/uninstall time by globbing `*.default-release` under the platform's Firefox profiles directory (macOS: `~/Library/Application Support/Firefox/Profiles`, Linux: `~/.mozilla/firefox`), since the profile folder name includes a random per-install prefix; if none or more than one match is found, linking/syncing is skipped with a logged message rather than guessing
- requires the **Userchrome Toggle Extended** and **Sidebery** Firefox addons, installed manually via Firefox's Add-ons Manager — neither the addons nor Userchrome Toggle Extended's Style 1/2/3 toggle state are portable, so re-enable/re-toggle them by hand after a fresh install

### Window management

- [`aerospace/aerospace.toml`](aerospace/aerospace.toml) -> `~/.config/aerospace/aerospace.toml` — requires AeroSpace itself, installed manually (see prerequisites above)
- `borders` (JankyBorders) draws the active-window border AeroSpace triggers on startup; `install.sh` installs it via Homebrew (`FelixKratz/formulae` tap) on macOS if missing

## Notes

- Existing files are moved out of the way before links are created.
- The bootstrap command needs `git` and network access.
- `DOTFILES_BACKUP_DIR` overrides where backups go; `bootstrap.sh` sets `DOTFILES_SKIP_PULL=1` so the repo isn't pulled a second time by `install.sh`.
- Shared helpers (paths, logging, the link table, Firefox profile lookup) live in [`lib/common.sh`](lib/common.sh).
- `DOTFILES_DIR`, `DOTFILES_REPO_URL`, and `DOTFILES_BRANCH` can be set before running `bootstrap.sh`.

## Uninstall

```bash
cd ~/dev/dotfiles
./uninstall.sh
```

Pass component names to remove only those links (`./uninstall.sh tmux`). This removes symlinks created by the repo. It does not remove `~/.oh-my-zsh`, installed CLI tools, downloaded tmux plugins, your `zsh/environment.zsh`, or the copied Firefox `chrome/` directory.
