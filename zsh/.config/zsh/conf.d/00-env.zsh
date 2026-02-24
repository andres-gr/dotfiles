# zsh/.config/zsh/conf.d/00-env.zsh

# (optional profiling -- uncomment to profile)
# zmodload zsh/zprof

# locale
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"

# add local user bin
export PATH="$HOME/.local/bin:$PATH"

# bun - if present, integrate
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
if [ -s "$BUN_INSTALL/_bun" ]; then
  source "$BUN_INSTALL/_bun"
fi
export PATH="$BUN_INSTALL/bin:$PATH"

# bat theme
export BAT_THEME="${BAT_THEME:-Dracula}"

# Homebrew curl flags (guarded; handle Intel & Apple Silicon prefixes)
if [[ -d "/usr/local/opt/curl" ]]; then
  export PATH="/usr/local/opt/curl/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/curl/lib ${LDFLAGS:-}"
  export CPPFLAGS="-I/usr/local/opt/curl/include ${CPPFLAGS:-}"
fi

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/opt/curl" ]]; then
    export PATH="$BREW_PREFIX/opt/curl/bin:$PATH"
    export LDFLAGS="-L${BREW_PREFIX}/opt/curl/lib ${LDFLAGS:-}"
    export CPPFLAGS="-I${BREW_PREFIX}/opt/curl/include ${CPPFLAGS:-}"
  fi
fi

# common sbin (macOS)
[[ -d "/usr/local/sbin" ]] && export PATH="/usr/local/sbin:$PATH"

# Ruby gem bin (robust)
if command -v gem >/dev/null 2>&1; then
  GEM_BINDIR="$(ruby -e 'print Gem.user_dir + "/bin"' 2>/dev/null || true)"
  if [[ -n "$GEM_BINDIR" && -d "$GEM_BINDIR" ]]; then
    export PATH="$GEM_BINDIR:$PATH"
  else
    GEMDIR="$(gem environment gemdir 2>/dev/null || true)"
    [[ -n "$GEMDIR" ]] && export PATH="$GEMDIR/bin:$PATH"
  fi
fi

# pnpm
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export PATH="$PNPM_HOME:$PATH"

# Spicetify
export PATH="$PATH:$HOME/.spicetify"
