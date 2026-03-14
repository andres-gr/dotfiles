# dirs.zsh — directory navigation helpers
# Works on both macOS and Arch/HyDE.
# unalias is harmless if the alias doesn't exist (2>/dev/null suppresses error).

# go up n directories — HyDE aliases c='clear', so unalias first
unalias c 2>/dev/null
c() {
  local count=${1:-1}
  cd $(printf "%0.s../" $(seq 1 $count))
}

# yazi with cwd file — HyDE has no alias y, but guard anyway
unalias y 2>/dev/null
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
