# 05-path.zsh
# Deterministic PATH configuration

typeset -U path PATH  # remove duplicates

# Base
path=(
  "$HOME/.local/bin"
  $path
)

# macOS (Homebrew)
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -d "/opt/homebrew/bin" ]] && path=(/opt/homebrew/bin $path)
  [[ -d "/usr/local/bin" ]] && path=(/usr/local/bin $path)
  [[ -d "/usr/local/sbin" ]] && path+=(/usr/local/sbin)
fi

# Arch / Linux
if [[ "$OSTYPE" == linux* ]]; then
  [[ -d "/usr/local/sbin" ]] && path+=(/usr/local/sbin)
fi

# Bun
[[ -d "$BUN_INSTALL/bin" ]] && path+=("$BUN_INSTALL/bin")

# pnpm (portable)
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
[[ -d "$PNPM_HOME" ]] && path+=("$PNPM_HOME")

# Spicetify
export SPICETIFY_HOME="${SPICETIFY_HOME:-$HOME/.spicetify}"
[[ -d "$SPICETIFY_HOME" ]] && path+=("$SPICETIFY_HOME")

[[ -d "$HOME/.config/zsh/bin" ]] && path+=("$HOME/.config/zsh/bin")

export PATH
