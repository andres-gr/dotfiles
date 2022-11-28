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
export CONFIGS_DIR="$HOME/devel/configs"
export PATH="$HOME/neovim/bin:$PATH"

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# plugins
source $CONFIGS_DIR/plugins.zsh

# aliases
source $CONFIGS_DIR/alias.zsh

# keybinds
# source $CONFIGS_DIR/keybinds.zsh

# funtions
source $CONFIGS_DIR/functions.zsh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

# Ruby init
if [ -d "/usr/local/opt/ruby/bin" ]; then
  export PATH=/usr/local/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi
# end Ruby init

# set path updates
export PATH

# set misc variables
FAST_HIGHLIGHT_STYLES[suffix-alias]='fg=green'
FAST_HIGHLIGHT_STYLES[precommand]='fg=green'
FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=cyan'

# init fnm
eval "$(fnm env --use-on-cd)"

# eval "$(starship init zsh)"
_evalcache starship init zsh

