# 70-aliases.zsh — tool-aware aliases (migrated from zsh/alias.zsh)

# Prefer modern tools if present
if command -v eza >/dev/null 2>&1; then
  alias l='eza -lha --icons=auto --sort=name --group-directories-first'
  alias ll='eza -lh --icons=auto'
  alias lt='eza --icons=auto --tree'
  alias ls='eza -1 --icons=auto'
  alias ld='eza -lhD --icons=auto'
else
  alias l='ls -lha'
  alias ll='ls -lh'
  alias ls='ls -1'
fi

command -v bun >/dev/null 2>&1 && alias b="bun"
command -v brew >/dev/null 2>&1 && alias bdump="brew bundle dump -f"
command -v code >/dev/null 2>&1 && alias co="code ."

if command -v fnm >/dev/null 2>&1; then
  alias fu="fnm use"
  alias fud="fnm use default"
fi

command -v lolcat >/dev/null 2>&1 && alias lc="lolcat"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"
command -v tmux >/dev/null 2>&1 && alias tm="tmux"

if command -v nvim >/dev/null 2>&1; then
  alias n="nvim"
  alias v="nvim"
  alias vo="nvim ."
fi

# General aliases (preserved)
alias mkd="mkdir -p"
alias weather="curl v2.wttr.in"

# git helper preserved
command -v git_current_branch >/dev/null 2>&1 && alias gpsup='git_current_branch | git push --set-upstream origin'
