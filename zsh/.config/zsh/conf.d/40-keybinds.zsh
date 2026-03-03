# 40-keybinds.zsh
# Keybindings (minimal, portable, safe)

# --------------------------------------------------
# Keymap
# --------------------------------------------------
bindkey -v   # vim mode

# --------------------------------------------------
# fzf history (Ctrl + R) — safe binding
# --------------------------------------------------
(( $+widgets[fzf-history-widget] )) && bindkey '^R' fzf-history-widget

# --------------------------------------------------
# History search with arrows (type then ↑)
# --------------------------------------------------
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# --------------------------------------------------
# Word movement (Alt + arrows)
# --------------------------------------------------
# Modern terminals
bindkey '^[^[[C' forward-word
bindkey '^[^[[D' backward-word

# Fallback escape sequences
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# --------------------------------------------------
# Clear screen (Ctrl + O)
# --------------------------------------------------
bindkey '^O' clear-screen
