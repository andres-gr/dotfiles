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

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

typeset -U path
typeset -U fpath

export TERM="xterm-256color"
export CONFIGS_DIR="$HOME/devel/configs/"

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/andres/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# [ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}

# plugins
source $CONFIGS_DIR/plugins.zsh

# aliases
source $CONFIGS_DIR/alias.zsh

# keybinds
source $CONFIGS_DIR/keybinds.zsh

# pnpm
export PNPM_HOME="/Users/andres/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# Ruby env setup
#
export RBENV_ROOT="/usr/local/var/rbenv"
if which rbenv > /dev/null; then _evalcache rbenv init -; fi
source $(dirname $(gem which colorls))/tab_complete.sh
#
# Ruby env setup end

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# eval "$(starship init zsh)"
_evalcache starship init zsh

