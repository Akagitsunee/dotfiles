ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  docker
  brew
  node
  git-auto-fetch
  npm
  autojump
  git-flow-completion
  zsh-completions
  enhancd
  k
  zsh-autosuggestions
  zsh-syntax-highlighting
  tmux
  tmux-cssh
  tmuxinator
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export SSH="$HOME/.ssh"

alias pip='/usr/local/bin/pipx'
alias anime='cd ~/Anime'
alias series='cd ~/Series'
alias zshc='nvim ~/.zshrc'
alias gstyc='nvim ~/.config/ghostty/config'
alias nvimc='nvim ~/.config/nvim'
alias rmrf='rm -rf'
alias bizdev='cd ~/bizdev'
alias dev='cd ~/dev'
alias cfg='cd ~/.config'
alias cnv='cd ~/.config/nvim'
alias cwt='cd ~/.config/wezterm'
alias cg='cd ~/.config/ghostty'
alias ctm='cd ~/.config/tmux'
alias tc='nvim ~/.config/ghostty'
alias c='clear'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias npm='pnpm'
alias vim='nvim'
alias dotfiles='cd ~/dev/dotfiles'
alias joyn='cd ~/dev/golang/joyn-downloader'
alias zshs='source ~/.zshrc'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

if [ "$TERM_PROGRAM" = "vscode" ] && command -v code >/dev/null 2>&1; then
  . "$(code --locate-shell-integration-path zsh)"
fi

if command -v borders >/dev/null 2>&1; then
  borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=2.0 >/dev/null 2>&1 &
fi

autoload -U +X bashcompinit && bashcompinit

if [ -x /usr/local/bin/terraform ]; then
  complete -o nospace -C /usr/local/bin/terraform terraform
fi
