# functions/git.zsh — small git helpers migrated from functions.zsh
glog() {
  git log --oneline --graph --decorate --all
}

fgb() {
  # fuzzy checkout for local branches (kept your original behavior)
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) && git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
