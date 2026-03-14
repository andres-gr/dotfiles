# plugins.zsh — minimal, deferred plugins via zinit
# Guard: set by plugin.zsh on HyDE; checked by .zshrc on macOS/non-HyDE
# to prevent double-loading.
typeset -g _NEO_PLUGINS_LOADED=1

# --------------------------------------------------
# Locate Zinit
# --------------------------------------------------

# Tell Zinit where to put the compdump (must be set before sourcing zinit)
typeset -gA ZINIT
ZINIT[ZCOMPDUMP_PATH]="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

# Locate zinit — check user install first, then system, then Homebrew
_zinit_paths=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"  # user install (default)
  "/usr/share/zinit/zinit.zsh"                                       # system (Arch pkg)
  "/opt/homebrew/opt/zinit/zinit.zsh"                                # Homebrew Apple Silicon
  "/usr/local/opt/zinit/zinit.zsh"                                   # Homebrew Intel
)
for _zinit_path in "${_zinit_paths[@]}"; do
  [[ -f "$_zinit_path" ]] && { source "$_zinit_path"; break; }
done
unset _zinit_path _zinit_paths

# Bail if zinit didn't load
(( $+functions[zinit] )) || return

# Do nothing, but remove zinit's zi alias -- conflicts with z.lua and zoxide
zinit ice wait"0" lucid atinit"unalias zi zini zpl zplg" silent
zinit snippet /dev/null

# ----------------------------------------
# sudo — double-ESC to prepend sudo to current/previous command
# Only unique feature from OMZ we want to keep
# ----------------------------------------
zinit ice wait"0" lucid silent
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

# ----------------------------------------
# Autosuggestions
# atinit: start the suggestion engine immediately after load
# ----------------------------------------
zinit ice wait"0" lucid silent atload"_zsh_autosuggest_start"
zinit load zsh-users/zsh-autosuggestions

# ----------------------------------------
# Autopair
# ----------------------------------------
zinit ice wait"0" lucid silent
zinit load hlissner/zsh-autopair

# ----------------------------------------
# Syntax Highlighting — must load after autosuggestions
# ----------------------------------------
zinit ice wait"0.1" lucid silent
zinit load zdharma-continuum/fast-syntax-highlighting

# ----------------------------------------
# Custom Highlight Styles
# (applied after plugin loads)
# ----------------------------------------

typeset -gA FAST_HIGHLIGHT_STYLES
FAST_HIGHLIGHT_STYLES[path-to-dir]="fg=cyan"
FAST_HIGHLIGHT_STYLES[precommand]="fg=green"
FAST_HIGHLIGHT_STYLES[suffix-alias]="fg=green"
