export PLUGINS_DIR="$HOME/devel/plugins"

# omz completions plugin
source $PLUGINS_DIR/ohmyzsh/lib/completion.zsh

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit zrecompile

# git plugin
source $PLUGINS_DIR/git/git.plugin.zsh

# tmux plugin settings
export ZSH_TMUX_AUTOSTART=true
source $PLUGINS_DIR/ohmyzsh/plugins/tmux/tmux.plugin.zsh

# fast syntax highlight plugin
source $PLUGINS_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# zsh autosuggestions plugin
source $PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh

 # zsh completions plugin
fpath=("$PLUGINS_DIR/zsh-completions/src" $fpath)

# zsh history substring plugin and settings
source $PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh

# arrows up down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# emacs ctrl p ctrl n
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# vim j k
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# common zsh aliases plugin
source $PLUGINS_DIR/ohmyzsh/plugins/common-aliases/common-aliases.plugin.zsh

# pnpm plugin
source $PLUGINS_DIR/omz-plugin-pnpm/pnpm.plugin.zsh

# eval cache plugin
source $PLUGINS_DIR/evalcache/evalcache.plugin.zsh
