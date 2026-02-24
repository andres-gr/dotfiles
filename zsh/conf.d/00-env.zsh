# 00-env.zsh — environment variables pulled from your old home .zshrc
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"

# repository layout & helper paths (kept from your old file)
export DOTFILES="${DOTFILES:-$HOME/devel/dotfiles}"
export ZSH_FILES="${ZSH_FILES:-$DOTFILES/zsh}"

# local bin / dotfiles bin
export PATH="$ZDOTDIR/bin:$HOME/.local/bin:$PATH"

# pnpm and bun (preserve your old envs)
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export PATH="$PNPM_HOME:$PATH"

export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PATH="$BUN_INSTALL/bin:$PATH"

# misc: keep bat theme
export BAT_THEME="${BAT_THEME:-Dracula}"

# history file path (XDG)
export HISTFILE="$XDG_STATE_HOME/zsh/history"
