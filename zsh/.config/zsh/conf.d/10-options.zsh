# 10-options.zsh
# Core shell behavior

# ---------------------------
# History
# ---------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# ---------------------------
# Navigation
# ---------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ---------------------------
# Globbing
# ---------------------------
setopt EXTENDED_GLOB
setopt GLOB_DOTS
unsetopt NOMATCH   # don't error on unmatched globs

# ---------------------------
# Completion behavior
# ---------------------------
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# ---------------------------
# Safety / usability
# ---------------------------
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt MULTIOS
