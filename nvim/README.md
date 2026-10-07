# Neovim Config

Personal Neovim configuration extracted from my dotfiles and built on top of a `lazy.nvim` plugin layout.

This started from `kickstart.nvim`, but it is no longer documented or organized as a starter template. The config is now opinionated around my own workflow, UI defaults, language support, and plugin choices.

## What This Config Includes

- `lazy.nvim` for plugin management
- Modular Lua config under `lua/config` and `lua/plugins`
- Shared global design/config table in `lua/config/globals.lua`
- Base46/NvChad theme integration with theme persistence and transparency toggle
- `blink.cmp` completion with `LuaSnip`
- Built-in LSP setup via `nvim-lspconfig`, `mason.nvim`, and `lspsaga.nvim`
- Formatting with `conform.nvim`
- Linting with `nvim-lint`
- File management with `oil.nvim`
- Fuzzy finding via `snacks.nvim`
- Git integration with `gitsigns.nvim`
- Custom error logging to `~/.config/nvim/.logs/nvim-errors.log`

## Structure

```text
.
├── init.lua
├── lua/config/        # bootstrap, options, keymaps, autocmds, globals
├── lua/plugins/core/  # lsp, completion, treesitter, debugging
├── lua/plugins/editor/# editing, navigation, file management, git
├── lua/plugins/tools/ # formatting, utilities
├── lua/plugins/ui/    # colorscheme, statusline, notifications, interface
├── lua/plugins/languages/
└── after/ftplugin/    # filetype-specific overrides
```

## Requirements

At minimum:

- Neovim `stable`
- `git`
- `ripgrep`
- `fd`
- a Nerd Font
- a clipboard provider for your OS
- build tooling for native plugins: `make` and a C compiler (`blink.cmp`/`blink.pairs` download prebuilt binaries, so no `cargo`)

Language tooling depends on what you edit, but this config is set up to make use of:

- `node` / `npm` for TypeScript, JavaScript, HTML, CSS, JSON, Markdown, Svelte, Vue, and Prettier-based tooling
- `go` for Go support (optional: `gopls`, `goimports`, `gofumpt`, `golangci-lint` and `delve` are only installed by Mason when `go` is on `$PATH`; everything else needs just Node)
- Mason-managed tools like `lua_ls`, `vtsls`, `gopls`, `yamlls`, `eslint_d`, `prettierd`, `stylua`, `shfmt`, `shellcheck`, `golangci-lint`, and others

## Install

This config currently lives inside a broader dotfiles repo. The normal setup is the top-level [bootstrap command](../README.md#install), which clones to `~/dev/dotfiles` and symlinks everything, including this directory, into place. To set up just this piece manually:

```sh
git clone git@github.com:Akagitsunee/dotfiles.git ~/dev/dotfiles
ln -s ~/dev/dotfiles/nvim ~/.config/nvim
```

If you manage dotfiles some other way, the only requirement is that this directory ends up at Neovim's config path.

Then launch Neovim:

```sh
nvim
```

On first start, `lazy.nvim` will bootstrap itself and install plugins. Mason will then install configured language servers and external tools.

## Useful Commands

- `:Lazy` to inspect plugin state
- `:Mason` to inspect LSP/tool installation
- `:Format` to format the current buffer
- `:FormatToggle` to toggle format-on-save
- `:LintBuffer` to run linting for the current buffer
- `:LintInfo` to show active linters for the current filetype
- `:ToggleTransparency` to switch transparent background on or off
- `:ThemeInfo` to inspect current theme settings
- `:OpenErrorLog` to open the config error log

## Notes

- Theme state is persisted through `lua/nvconfig.lua`; the compiled base46 cache (`.base46_cache/`) is only rebuilt when the theme or the transparency setting changes (stamp in `$XDG_STATE_HOME/nvim/base46.stamp`), not on every start
- Floating windows (pickers, Lazy, which-key, completion menu) are always opaque: `ui.blend`/`ui.winblend` are `0` in `lua/config/globals.lua` because any value above 0 lets the text underneath bleed through blank cells. `:ToggleTransparency` / `<leader>ut` only makes the editor background, statusline and file tree transparent
- Formatting uses `prettierd`, which takes no CLI flags; its fallback options (2 spaces, single quotes) live in `prettierrc.json` and are only used when a project has no prettier config of its own
- The external theme sync (`lua/config/theme_sync.lua`) only runs inside Ghostty/tmux with a UI attached, writes files only when their content changed, and restores the originals on exit
- Keymaps worth knowing: `gsa/gsd/gsr` surround (mini.surround), `]c`/`[c` next/previous git hunk, `]]`/`[[`/`][`/`[]` class motions (treesitter textobjects), `<leader>ll` Lazy, `<leader>W` write and quit, `<leader>Q` quit all, `Ctrl h/j/k/l` move between nvim splits and tmux panes (vim-tmux-navigator; the tmux half is in `tmux/tmux.conf`), `<C-y>` accept completion (`<C-Space>` is the tmux prefix and never reaches nvim)
- Files over 1 MB are flagged with `vim.b.large_file`: no treesitter, no LSP attach, no format-on-save, syntax off (the flag is buffer-local, other buffers are unaffected)
- Filetype-specific tweaks live under `after/ftplugin`
- This config disables several builtin providers/plugins intentionally to reduce startup noise and overhead
- `doc/kickstart.txt` is leftover reference material from the original starting point, not the source of truth for this config

## Using It Alongside Another Config

Use `NVIM_APPNAME` if you want to keep this config separate from your main setup:

```sh
alias kitsune='NVIM_APPNAME="kitsune" nvim'
```

Then place this config at:

```sh
~/.config/kitsune

