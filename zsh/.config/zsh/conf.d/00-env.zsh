# 00-env.zsh
# Shell environment (interactive safe)

# Locale (safe default)
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-$LANG}"

# Editor
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export PAGER="${PAGER:-less}"

# BAT
export BAT_THEME="${BAT_THEME:-Dracula}"

# Bun (no heavy logic)
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
[[ -r "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
