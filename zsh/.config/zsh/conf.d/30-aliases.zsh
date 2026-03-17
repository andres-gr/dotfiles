# 30-aliases.zsh
# Tool-aware aliases (fast, zsh-native)

# --------------------------------------------------
# eza / ls
# --------------------------------------------------
if (( $+commands[eza] )); then
  alias l='eza -lha --icons=auto --sort=name --group-directories-first'
  alias ll='eza -lh --icons=auto'
  alias lt='eza --tree --icons=auto'
  alias ls='eza -1 --icons=auto'
  alias ld='eza -lhD --icons=auto'
else
  alias l='ls -lha'
  alias ll='ls -lh'
  alias ls='ls -1'
fi

# --------------------------------------------------
# Editors
# --------------------------------------------------
if (( $+commands[nvim] )); then
  alias n='nvim'
  alias v='nvim'
  alias vo='nvim .'
fi

# --------------------------------------------------
# Dev tools
# --------------------------------------------------
(( $+commands[brew] ))     && alias bdump='brew bundle dump -f'
(( $+commands[bun] ))      && alias b='bun'
(( $+commands[claude] ))   && alias cl='claude'
(( $+commands[code] ))     && alias co='code .'
(( $+commands[fnm] ))      && alias fu='fnm use'
(( $+commands[fnm] ))      && alias fud='fnm use default'
(( $+commands[lazygit] ))  && alias lg='lazygit'
(( $+commands[lolcat] ))   && alias lc='lolcat'
(( $+commands[tmux] ))     && alias tm='tmux'

# --------------------------------------------------
# Utilities
# --------------------------------------------------
alias mkd='mkdir -p'
alias weather='curl v2.wttr.in'

# --------------------------------------------------
# Git helpers
# --------------------------------------------------
(( $+commands[git_current_branch] )) && alias gpsup='git push --set-upstream origin $(git_current_branch)'

# --------------------------------------------------
# Git (OMZ-inspired)
# --------------------------------------------------
alias g='git'
alias gst='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias glog='git log --oneline --graph --decorate'
