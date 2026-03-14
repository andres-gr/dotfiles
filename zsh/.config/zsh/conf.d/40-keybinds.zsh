# 40-keybinds.zsh
# Keybindings (minimal, portable, safe)

# --------------------------------------------------
# Keymap
# --------------------------------------------------
bindkey -v   # vim mode
bindkey -M viins 'jj' vi-cmd-mode # ----------------
bindkey -M viins 'jk' vi-cmd-mode # Exit vi insert mode
bindkey -M viins 'kj' vi-cmd-mode # ----------------

bindkey -M visual 'jk' deactivate-region # Exit vi visual mode
bindkey -M visual 'kj' deactivate-region # ---------

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

# --------------------------------------------------
# Ctrl+[: accept autosuggestion if showing, else complete
# --------------------------------------------------
# Registered via precmd so it runs after zsh-autosuggestions deferred load.
# $POSTDISPLAY holds the ghost text — non-empty means a suggestion is visible.
_neo_bind_autosuggest_accept() {
  _neo_accept_suggestion() {
    if [[ -n "$POSTDISPLAY" ]]; then
      zle autosuggest-accept
    else
      zle expand-or-complete
    fi
  }
  zle -N _neo_accept_suggestion
  bindkey '^[' _neo_accept_suggestion
  # Remove ourselves — only needs to run once
  precmd_functions=( ${precmd_functions:#_neo_bind_autosuggest_accept} )
}
precmd_functions+=(_neo_bind_autosuggest_accept)
