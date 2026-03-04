# plugins.zsh — minimal, HyDE-inspired + custom highlighting

# --------------------------------------------------
# Locate Zinit
# --------------------------------------------------

# Tell Zinit where to put the compdump (must be set before sourcing zinit)
typeset -gA ZINIT
ZINIT[ZCOMPDUMP_PATH]="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

if [[ -f "/opt/homebrew/opt/zinit/zinit.zsh" ]]; then
  source "/opt/homebrew/opt/zinit/zinit.zsh"
elif [[ -f "/usr/local/opt/zinit/zinit.zsh" ]]; then
  source "/usr/local/opt/zinit/zinit.zsh"
elif [[ -f "/usr/share/zinit/zinit.zsh" ]]; then
  source "/usr/share/zinit/zinit.zsh"
else
  return
fi

zinit ice lucid

# Do nothing, but remove zinit's zi alias -- conflicts with z.lua and zoxide
zinit ice wait"0" atinit"unalias zi zini zpl zplg" silent
zinit snippet /dev/null

# ----------------------------------------
# Autosuggestions (load first)
# ----------------------------------------
zinit ice wait"0" silent
zinit load zsh-users/zsh-autosuggestions

# ----------------------------------------
# Autoparis (load next)
# ----------------------------------------
zinit ice wait"0" silent
zinit load hlissner/zsh-autopair

# ----------------------------------------
# Syntax Highlighting (must load last)
# ----------------------------------------
zinit ice wait"1" silent
zinit load zdharma-continuum/fast-syntax-highlighting

# ----------------------------------------
# Custom Highlight Styles
# (applied after plugin loads)
# ----------------------------------------

typeset -gA FAST_HIGHLIGHT_STYLES
FAST_HIGHLIGHT_STYLES[path-to-dir]="fg=cyan"
FAST_HIGHLIGHT_STYLES[precommand]="fg=green"
FAST_HIGHLIGHT_STYLES[suffix-alias]="fg=green"
