# MacOS shortcuts 
# -d (Display): Prevents the display from sleeping and stops the screensaver from turning on.
# -i (Idle): Prevents general system idle sleep.
# -m (Disk): Prevents the hard drive/disks from going idle or spinning down.
# -s (System): Prevents the entire system from sleeping when plugged into AC power.
# -u (User Active): Emulates user activity. This tricks macOS into thinking you are actively moving the mouse or typing, completely blocking screensaver timeouts.
alias stim='caffeinate -dimsu'

# System defaults
alias c='clear'
alias rmrf='rm -rf'
alias grep='rg --color=auto'
alias ls='eza'
alias vim='nvim'
alias npm='pnpm'
alias npx="pnpm dlx"
# Detailed listing
alias ll='eza -lh --icons --git'
# Detailed listing including hidden files
alias la='eza -lah --icons --git'
# Better tree
alias tree="eza --tree --icons --git-ignore"

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

# Better Python
# Force Python scripts to execute through uv's fast runtime engine
alias python3="uv run python"
alias python="uv run python"

# Force pip to use uv's blistering fast package installer
alias pip3="uv pip"
alias pip="uv pip"

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
