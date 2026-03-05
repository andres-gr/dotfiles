# functions/fzf.zsh — fzf helpers & defaults (migrated & consolidated)

# default fzf options (used by your fzf helpers)
# export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:--q --height 40% --layout=reverse --border}"

# your 'fo' function — open file(s) found with fzf
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# 'fh' search history helper (preserve behavior)
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# _fuzzy_edit and related helpers from configs (kept in functions; more advanced helpers are kept
# in the repo under zsh/bin/ and referenced here as needed).

# fuzzy find directory
fcd() {
  cd $(fd -t d -H\
    -E .git\
    -E node_modules\
    -E .cache\
    -E .npm\
    -E .local\
  | fzf)
}

# fuzzy grep via rg and open in nvim with line number
fgr() {
  local file
  local line

  read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]; then
    nvim $file +$line
  fi
}
