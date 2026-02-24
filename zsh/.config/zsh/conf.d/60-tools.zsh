# 60-tools.zsh — initialize heavy tools via evalcache when available
# prefer evalcache for caching eval outputs; fallback to direct eval or source

if command -v evalcache >/dev/null 2>&1; then
  command -v starship >/dev/null 2>&1 && evalcache starship init zsh
  command -v fnm >/dev/null 2>&1 && evalcache fnm env --use-on-cd
  command -v zoxide >/dev/null 2>&1 && evalcache zoxide init zsh
  command -v direnv >/dev/null 2>&1 && evalcache direnv hook zsh
  command -v fzf >/dev/null 2>&1 && evalcache fzf --zsh
else
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
  command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
  command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
  command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
fi
