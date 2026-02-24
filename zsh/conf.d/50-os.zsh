# 50-os.zsh — minimal OS detection & brew prefix handling
case "$(uname -s)" in
  Darwin*)
    if command -v brew >/dev/null 2>&1; then
      export HOMEBREW_PREFIX="$(brew --prefix)"
    fi
    ;;
  Linux*)
    # keep Linux-specific hooks empty — package installs are handled outside
    ;;
esac
