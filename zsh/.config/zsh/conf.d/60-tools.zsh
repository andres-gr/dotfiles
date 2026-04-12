# 60-tools.zsh
# Interactive tool initialization (portable, minimal)

# --------------------------------------------------
# Starship (prompt)
# --------------------------------------------------
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# --------------------------------------------------
# fnm (Node manager)
# --------------------------------------------------
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd)"
fi

# --------------------------------------------------
# zoxide (smart cd)
# --------------------------------------------------
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# --------------------------------------------------
# direnv
# --------------------------------------------------
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# --------------------------------------------------
# fzf (portable detection)
# --------------------------------------------------
if (( $+commands[fzf] )); then

  # Arch Linux location
  if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh 2>/dev/null

    # Homebrew Apple Silicon
  elif [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null

    # Homebrew Intel macOS
  elif [[ -r /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
    source /usr/local/opt/fzf/shell/key-bindings.zsh
    source /usr/local/opt/fzf/shell/completion.zsh 2>/dev/null
  fi
fi
