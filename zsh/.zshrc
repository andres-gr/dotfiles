# zmodload zsh/zprof

setopt nobeep

#Dracula theme colors
COLOR_DARK="#6272A4"
COLOR_CYAN="#80FFEA"
COLOR_GREEN="#8AFF80"
COLOR_ORANGE="#FFCA80"
COLOR_PINK="#FF80BF"
COLOR_PURPLE="#9580FF"
COLOR_RED="#FF9580"
COLOR_YELLOW="#FFFF80"
COLOR_WHITE="#F8F8F2"

# neofetch on init
# if [ -x "$(command -v neofetch)" ]; then neofetch; fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

typeset -U path
typeset -U fpath

export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES="$HOME/devel/dotfiles"
export ZSH_FILES="$DOTFILES/zsh"

# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# editor
export EDITOR=nvim

# plugins
source $ZSH_FILES/plugins.zsh

# aliases
source $ZSH_FILES/alias.zsh

# keybinds
source $ZSH_FILES/keybinds.zsh

# funtions
source $ZSH_FILES/functions.zsh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Spicetify
export PATH=$PATH:/Users/andres/.spicetify

# brew curl
export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

# brew sbin
export PATH="/usr/local/sbin:$PATH"

# Ruby init
if [ -d "/usr/local/opt/ruby/bin" ]; then
  export PATH=/usr/local/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

# local bin files path
export PATH="$HOME/.local/bin:$PATH"

# fzf rg
export PATH="$DOTFILES/zsh/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# set misc variables
FAST_HIGHLIGHT_STYLES[suffix-alias]="fg=green"
FAST_HIGHLIGHT_STYLES[precommand]="fg=green"
FAST_HIGHLIGHT_STYLES[path-to-dir]="fg=cyan"

# set bat theme
export BAT_THEME="Dracula"

# init fnm
eval "$(fnm env --use-on-cd)"

# eval "$(starship init zsh)"
_evalcache starship init zsh

# init z search
_evalcache zoxide init zsh
