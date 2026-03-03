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
zinit load zsh-users/zsh-syntax-highlighting

# ----------------------------------------
# Custom Highlight Styles
# (applied after plugin loads)
# ----------------------------------------

# After zsh-syntax-highlighting is loaded
typeset -gA ZSH_HIGHLIGHT_STYLES

# Aliases
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green'

# Builtins / commands
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta'

# Paths
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=blue'

# Flags
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'

# Fallback command word
ZSH_HIGHLIGHT_STYLES[arg0]='fg=white'

# Strings
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# Comments
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'

# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
