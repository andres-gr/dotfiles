# 50-tmux.zsh
# Minimal, safe tmux autostart

# Only if:
# - variable $_NO_TMUX is not set
# - tmux exists
# - not already inside tmux
# - not over SSH
# - attached to a real TTY
# - not inside VSCode

if [[ -z "$_NO_TMUX" ]] \
  && (( $+commands[tmux] )) \
  && [[ -z "$TMUX" ]] \
  && [[ -z "$SSH_CONNECTION" ]] \
  && [[ -n "$TERM_PROGRAM" && "$TERM_PROGRAM" != "vscode" ]] \
  && [[ -t 1 ]]; then

  exec tmux new-session -A -s main
fi
