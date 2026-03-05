# functions/tmux.zsh — tmux session helpers (ftm / tm)
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ "$1" ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s "$1" && tmux $change -t "$1")
    return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0)
  if [[ -n "$session" ]]; then
    tmux $change -t "$session"
  else
    echo "No sessions found."
  fi
}

# tm [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `tm` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftm` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}
