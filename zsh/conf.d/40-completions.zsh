# 40-completion.zsh — cached compinit for speed
if zsh -c 'true' >/dev/null 2>&1; then
  autoload -Uz compinit
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump" 2>/dev/null || compinit
fi
