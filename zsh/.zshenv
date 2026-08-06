# =========================================================
# XDG Base Directories
# =========================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Tell Zsh where its configuration lives
ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Oh My Zsh standard install location
export ZSH="$HOME/.oh-my-zsh"

# Keep the cache file clean
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${HOST}-${ZSH_VERSION}"

# =========================================================
# Language Runtimes & Tools (XDG Compliant)
# =========================================================
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"

# =========================================================
# Editor & Core Tools
# =========================================================
export EDITOR="nvim"
export VISUAL="nvim"
export SSH="$HOME/.ssh"
export GPG_TTY=$(tty)

# Pager configuration using 'bat'
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# =========================================================
# PATH Configuration
# =========================================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
export PATH="$GOBIN:$PATH"
export PATH="$HOME/go/bin:$PATH"
if [[ -d /opt/homebrew/opt/openjdk ]]; then
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
elif [[ -d /usr/local/opt/openjdk ]]; then
  export PATH="/usr/local/opt/openjdk/bin:$PATH"
fi
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="$PATH:$HOME/.spicetify"
