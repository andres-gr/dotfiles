# 20-completion.zsh
# Completion system (fast + XDG compliant)
#
# On HyDE, compinit is owned by HyDE's _load_compinit (terminal.zsh) which
# runs before .zshrc. We skip it here to avoid double-init overhead.
# On macOS / non-HyDE, we own compinit ourselves.

# --------------------------------------------------
# XDG cache location
# --------------------------------------------------
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# --------------------------------------------------
# Completion system
# --------------------------------------------------
# Skip if HyDE already ran _load_compinit (detected via its conf.d/hyde dir)
_neo_hyde_zsh="${ZDOTDIR:-$HOME/.config/zsh}/conf.d/hyde"
if [[ ! -d "$_neo_hyde_zsh" ]]; then
  autoload -Uz compinit
  _compdump="$ZSH_CACHE_DIR/.zcompdump"
  if [[ -f "$_compdump" ]]; then
    compinit -C -d "$_compdump"
  else
    compinit -d "$_compdump"
  fi
fi
unset _neo_hyde_zsh

# --------------------------------------------------
# Completion styles
# --------------------------------------------------

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# Bun completions
[[ -r "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
