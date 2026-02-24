# 30-keybinds.zsh — your keybinds (migrated verbatim)

# vim keybinds
bindkey -e

bindkey '^R' fzf-history-widget

# move one word forwards and backwards
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# rebind clear screen
bindkey "^O" clear-screen
