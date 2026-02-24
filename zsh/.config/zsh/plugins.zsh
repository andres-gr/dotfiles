# plugins.zsh — Antidote-only loader (no legacy PLUGINS_DIR fallback)
# - If a static bundle exists (.zsh_plugins.zsh) we source it (fastest).
# - Otherwise we require Antidote to be installed and load .zsh_plugins.txt.
#
# After migrating, remove any old PLUGINS_DIR usage.

ZSH_PLUGINS_FILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins.txt"
ZSH_BUNDLED_PLUGINS="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins.zsh"

# 1) Fast path: if a prebuilt static bundle exists, source it
if [ -r "$ZSH_BUNDLED_PLUGINS" ]; then
  # static bundle created by: antidote bundle < .zsh_plugins.txt > .zsh_plugins.zsh
  source "$ZSH_BUNDLED_PLUGINS"
  return 0
fi

# 2) Antidote dynamic load (required)
if command -v antidote >/dev/null 2>&1; then
  if [ -r "$ZSH_PLUGINS_FILE" ]; then
    # Antidote will clone/load plugins and cache them in its home.
    # This can be slower on first run; generating static bundle is recommended after testing.
    antidote load "$ZSH_PLUGINS_FILE"
    return 0
  else
    echo "plugins.zsh: ERROR: plugin list not found: $ZSH_PLUGINS_FILE" >&2
    return 1
  fi
fi

# If we reach here, Antidote is missing
echo "plugins.zsh: ERROR: Antidote is required. Install it and re-open the shell." >&2
echo "  macOS: brew install antidote" >&2
echo "  Arch:   yay -S antidote" >&2
return 1
