# functions/git.zsh — small git helpers migrated from functions.zsh
fgb() {
  # fuzzy checkout for local branches (kept your original behavior)
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) && git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# get current git branch
git_current_branch() {
  print "$(git branch --show-current)"
}

is_inside_git() {
  # See https://git.io/fp8Pa for related discussion
  [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]
}
