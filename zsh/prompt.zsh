# Initialize Prompt Engine
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Load custom styling layout if available
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Desktop Window Borders Modifiers
if command -v borders >/dev/null 2>&1; then
  (borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=2.0 >/dev/null 2>&1 &)
fi

