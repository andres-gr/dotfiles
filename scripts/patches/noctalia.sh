#!/usr/bin/env bash
# Noctalia post-install patches

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Zen Browser: Hide titlebar buttons via userChrome.css
###############################################################################

patch_zen_userchrome() {
  local src="$SCRIPT_DIR/data/noctalia-zen-override.css"
  local zen_config_dir="$HOME/.config/zen"

  # Find the default profile directory (ends with ".Default (release)")
  local -a profile_dirs
  mapfile -t profile_dirs < <(
    find "$zen_config_dir" -maxdepth 1 -type d -name '*.Default (release)' 2>/dev/null || true
  )

  if (( ${#profile_dirs[@]} == 0 )); then
    log "Zen Browser profile not found — skipping userChrome.css patch"
    return 0
  fi

  local chrome_dir="${profile_dirs[0]}/chrome"
  local css_file="$chrome_dir/userChrome.css"

  # Create chrome directory if it doesn't exist
  if [[ ! -d "$chrome_dir" ]]; then
    log "Creating Zen chrome directory: $chrome_dir"
    run mkdir -p "$chrome_dir"
  fi

  # Copy overwrite the patch css file
  cp -f "$src" "$chrome_dir"

  # CSS snippet to add
  local css_snippet="@import \"./noctalia-zen-override.css\";"

  # Check if the snippet already exists
  if [[ -f "$css_file" ]] && grep -q "noctalia-zen-override" "$css_file" 2>/dev/null; then
    log "userChrome.css: noctalia override import already present — skipping"
    return 0
  fi

  # Append the CSS snippet
  if $DRY_RUN; then
    log "[dry-run] would append to $css_file:"
    log "$css_snippet"
  else
    log "Patching $css_file"
    printf '\n%s\n' "$css_snippet" >> "$css_file"
    ok "  Added Noctalia override import to userChrome.css"
  fi
}

###############################################################################
# Spotify Toast plugin
# Clone or update the noctalia-spotify-toast plugin
###############################################################################

install_spotify_toast_plugin() {
  local plugin_dir="$HOME/.config/noctalia/plugins/noctalia-spotify-toast"
  local repo_url="https://github.com/andres-gr/noctalia-spotify-toast"

  # Create plugins directory if it doesn't exist
  if [[ ! -d "$(dirname "$plugin_dir")" ]]; then
    mkdir -p "$(dirname "$plugin_dir")"
  fi

  if [[ -d "$plugin_dir" ]]; then
    # Already exists — check if it's a git repo
    if [[ -d "$plugin_dir/.git" ]]; then
      log "Spotify Toast plugin found, pulling latest..."
      if $DRY_RUN; then
        log "[dry-run] would cd to $plugin_dir and git pull"
      else
        if cd "$plugin_dir" && git pull --ff-only 2>/dev/null; then
          ok "Updated Spotify Toast plugin"
        else
          warn "Spotify Toast plugin: git pull failed or no remote — skipping update"
        fi
      fi
    else
      log "Spotify Toast plugin directory exists but is not a git repo — skipping"
    fi
  else
    # Clone the repo
    log "Cloning Spotify Toast plugin..."
    if $DRY_RUN; then
      log "[dry-run] would git clone $repo_url to $plugin_dir"
    else
      if git clone --depth 1 "$repo_url" "$plugin_dir" 2>/dev/null; then
        ok "Cloned Spotify Toast plugin"
      else
        warn "Failed to clone Spotify Toast plugin"
      fi
    fi
  fi
}

###############################################################################
# Main entry point
###############################################################################

noctalia_patches() {
  step "Applying Noctalia patches"
  patch_zen_userchrome
  install_spotify_toast_plugin
}

# Export function
export -f noctalia_patches
