# neo-hyde.zsh — neo-dots HyDE-specific zsh overrides
# Sourced from $ZDOTDIR/user.zsh via a single line injected by install.sh.
# All HyDE overrides live here. Never edit user.zsh directly.
#
# To change NEO_GREETING per-machine, override in conf.d/99-local.zsh.
# To change HyDE-specific settings per-machine, add overrides AFTER the
# source line in user.zsh.

# --------------------------------------------------
# Prompt
# --------------------------------------------------
# Dotfiles owns starship init via conf.d/60-tools.zsh — disable HyDE's loader
HYDE_ZSH_PROMPT=0

# --------------------------------------------------
# Completion
# --------------------------------------------------
# Run compinit security check at most once per 24h (HyDE default is 1h)
HYDE_ZSH_COMPINIT_CHECK=24

# --------------------------------------------------
# HyDE alias overrides
# --------------------------------------------------
# terminal.zsh sets alias c='clear' AFTER
# _load_functions runs (so after our dirs.zsh defines c()). This one-shot
# precmd hook fires before the first prompt, clears those aliases, and
# removes itself so it never runs again.
_neo_override_hyde_aliases() {
  unalias c  2>/dev/null
  precmd_functions=( ${precmd_functions:#_neo_override_hyde_aliases} )
}
precmd_functions+=(_neo_override_hyde_aliases)
