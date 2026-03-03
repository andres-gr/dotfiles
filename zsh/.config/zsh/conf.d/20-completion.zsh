# 20-completion.zsh
# Completion system (fast + XDG compliant)

# --------------------------------------------------
# XDG cache location
# --------------------------------------------------
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# --------------------------------------------------
# Completion system
# --------------------------------------------------
autoload -Uz compinit

# Use cached dump file
_compdump="$ZSH_CACHE_DIR/.zcompdump"

# Fast init:
# -C skips security checks after first run
# -d sets dump location
if [[ -f "$_compdump" ]]; then
  compinit -C -d "$_compdump"
else
  compinit -d "$_compdump"
fi

# --------------------------------------------------
# Completion styles
# --------------------------------------------------

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# Bun completions
[[ -r "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
