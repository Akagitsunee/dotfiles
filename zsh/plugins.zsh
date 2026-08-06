# Fix Oh My Zsh security warnings
ZSH_DISABLE_COMPFIX=true

# List of frameworks plugins
plugins=(
  git docker brew node git-auto-fetch npm autojump
  git-flow-completion zsh-completions enhancd k
  zsh-autosuggestions zsh-syntax-highlighting tmux
  tmux-cssh tmuxinator zoxide
)

# Initialize framework core
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# 1. Force Zsh to initialize its internal core completion engine immediately
# (This fixes the 'command not found: compdef' error permanently)
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# 2. Safely load the Bash transition layer on top of it
autoload -U +X bashcompinit && bashcompinit

# Enable interactive completion menu selection (arrow keys)
zstyle ':completion:*' menu select

# Make completion case-insensitive (e.g., "doc" completes to "Documents")
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
