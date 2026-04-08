# ~/.config/zsh/.zshrc

# --------------------------------------------------
# Interactive guard
# --------------------------------------------------
[[ $- != *i* ]] && return

# --------------------------------------------------
# Load modular configuration
# --------------------------------------------------
if [[ -z "${_NEO_CONFD_LOADED:-}" ]]; then
  typeset -g _NEO_CONFD_LOADED=1
  for file in "$ZDOTDIR"/conf.d/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# --------------------------------------------------
# Load plugins
# --------------------------------------------------
# On HyDE: already loaded via plugin.zsh — _NEO_PLUGINS_LOADED is set.
# On macOS / non-HyDE: load here.
if [[ -z "${_NEO_PLUGINS_LOADED:-}" ]]; then
  [[ -r "$ZDOTDIR/plugins.zsh" ]] && source "$ZDOTDIR/plugins.zsh"
fi

# bun completions
[ -s "/Users/andres/.bun/_bun" ] && source "/Users/andres/.bun/_bun"

# --------------------------------------------------
# Load zsh functions
# --------------------------------------------------
if [[ -z "${_NEO_FUNCS_LOADED:-}" ]]; then
  typeset -g _NEO_FUNCS_LOADED=1
  for file in "$ZDOTDIR"/functions/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# --------------------------------------------------
# Greeting
# --------------------------------------------------
# Runs after all plugins load. NEO_GREETING set in conf.d/00-env.zsh.
# Override per-machine in conf.d/99-local.zsh.
case "${NEO_GREETING:-fastfetch}" in
  pokego)
    if (( $+commands[pokego] )); then
      pokego --nt -r 1,2
    elif (( $+commands[fastfetch] )); then
      fastfetch
    fi ;;
  fastfetch)
    (( $+commands[fastfetch] )) && fastfetch ;;
  none) ;;
esac
