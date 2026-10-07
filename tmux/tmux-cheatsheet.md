# Tmux Cheatsheet

Config: `~/.config/tmux/tmux.conf` (linked from this repo by `./install.sh tmux`).
Prefix: `Ctrl + Space` (written `Prefix` below). Press it, release, then press the key.

## Sessions (shell)

```
tmux new -s NewSession     # start a named session
tmux ls                    # list sessions
tmux attach -t NewSession  # go back into a session
```

Ghostty starts `tmux attach || tmux` for you, so a new terminal window lands in tmux.

## Windows and panes

| Keys | Action |
| --- | --- |
| `Prefix c` | New window (same directory) |
| `Prefix 1..9` | Go to window N (numbering starts at 1) |
| `Prefix n` / `Prefix p` | Next / previous window |
| `Prefix w` | Pick a window from a list |
| `Prefix ,` | Rename window |
| `Prefix \` | Split left/right (same directory) |
| `Prefix -` | Split top/bottom (same directory) |
| `Prefix m` | Zoom / unzoom the current pane |
| `Prefix h/j/k/l` | Resize the pane by 5 cells (repeatable) |
| `Prefix x` | Close the pane |

## Moving around (tmux + nvim)

| Keys | Action |
| --- | --- |
| `Ctrl h/j/k/l` | Move left/down/up/right across tmux panes **and** nvim splits |
| `Ctrl \` | Jump back to the previous pane/split |
| `Prefix Ctrl l` | Clear the screen (plain `Ctrl l` is taken by the navigation) |

The tmux half is the `vim-tmux-navigator` plugin, the nvim half is
`nvim/lua/plugins/editor/tmux.lua`; both are needed.

## Sessions inside tmux

| Keys | Action |
| --- | --- |
| `Prefix s` | Explore / switch sessions |
| `Prefix $` | Rename session |
| `Prefix d` | Detach |
| `Prefix Ctrl s` | Save sessions (tmux-resurrect) |
| `Prefix Ctrl r` | Restore sessions |

## Copy and paste

| Keys | Action |
| --- | --- |
| `Prefix [` | Enter copy mode (vi keys; scrolling with the trackpad works too) |
| `v` | Start selecting (in copy mode) |
| `y` | Copy to the macOS clipboard (`pbcopy`) and leave copy mode |
| `Esc` / `q` | Leave copy mode |
| `Prefix P` | Paste the tmux buffer (`Prefix p` is "previous window") |

With the mouse on, a drag selects text and keeps the selection until you press `y`.
Hold `Option` while dragging to use Ghostty's own selection instead.

## Config and plugins

| Keys | Action |
| --- | --- |
| `Prefix r` | Reload `tmux.conf` |
| `Prefix I` | Install plugins (TPM) |
| `Prefix U` | Update plugins |

Plugins live in `~/.config/tmux/plugins`. `./install.sh tmux` clones TPM and the plugins,
or press `Prefix I` after a manual clone:

```
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

## macOS notes

- Turn off System Settings > Keyboard > Keyboard Shortcuts > Input Sources > "Select the
  previous input source" (`Ctrl + Space`), otherwise macOS eats the prefix.
- `Ctrl + Space` is the prefix, so nvim never receives it (nvim accepts completions with
  `Tab` / `Ctrl y`).
- `Option` acts as `Alt` (`macos-option-as-alt = true` in `ghostty/config`).
