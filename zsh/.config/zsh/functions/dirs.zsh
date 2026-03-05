# go up n directories
c() {
  re='^[0-9]+$'
  count=1

  if ! [[ $num =~ $re ]]; then
    count=$num
  fi

  cd $(printf "%0.s../" $(seq 1 $1))
}

# yazi with cwd file
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
