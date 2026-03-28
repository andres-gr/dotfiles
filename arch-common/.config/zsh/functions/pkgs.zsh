 pkg() {
  local action="${1:-install}"
  local list="${2:-list.txt}"

  if [[ ! -f "$list" ]]; then
    echo "File not found: $list"
    return 1
  fi

  # Strip comments and blank lines
  local pkgs=($(sed 's/#.*//' "$list" | tr -s ' \t' '\n' | grep -v '^$'))

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    echo "No packages found in $list"
    return 1
  fi

  case "$action" in
    install|-S)
      yay -S --needed "${pkgs[@]}"
      ;;
    uninstall|remove|-R)
      yay -Rns "${pkgs[@]}"
      ;;
    *)
      echo "Usage: pkg [install|uninstall] [list.txt]"
      return 1
      ;;
  esac
}
