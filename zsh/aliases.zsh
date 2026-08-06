# System defaults
alias c='clear'
alias rmrf='rm -rf'
alias grep='rg --color=auto'
alias ls='eza'
alias vim='nvim'
alias pip='/usr/local/bin/pipx'
alias npm='pnpm'
# Detailed listing
alias ll='eza -lh --icons --git'
# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Navigation / Workspaces
alias anime='cd ~/Anime'
alias series='cd ~/Series'
alias bizdev='cd ~/bizdev'
alias dev='cd ~/dev'
alias dotfiles='cd ~/dev/dotfiles'
alias joyn='cd ~/dev/golang/joyn-downloader'
alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# Config shortcuts
alias cfg='cd ~/.config'
alias zshc='nvim ~/.config/zsh/.zshrc'
alias zshs='source ~/.config/zsh/.zshrc'
alias gstyc='nvim ~/.config/ghostty/config'
alias nvimc='nvim ~/.config/nvim'
alias cnv='cd ~/.config/nvim'
alias cwt='cd ~/.config/wezterm'
alias cg='cd ~/.config/ghostty'
alias ctm='cd ~/.config/tmux'
alias tc='nvim ~/.config/ghostty'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias ktmux='tmux kill-server; pkill -9 ghostty'

# JetBrains Toggle Function
jb() {
    if grep -q "# 127.0.0.1 account.jetbrains.com" /etc/hosts; then
        echo "🔓 Blocking JetBrains (Plugins Enabled)..."
        sudo sed -i '' '/jetbrains.com/s/^#\ //g' /etc/hosts
    else
        echo "🔒 Unblocking JetBrains (Trial Isolated)..."
        sudo sed -i '' '/jetbrains.com/s/^/#\ /g' /etc/hosts
    fi
}