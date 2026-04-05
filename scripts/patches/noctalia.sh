#!/usr/bin/env bash
# Noctalia post-install patches

###############################################################################
# Zen Browser: Hide titlebar buttons via userChrome.css
###############################################################################

patch_zen_userchrome() {
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

  # CSS snippet to add
  local css_snippet='.titlebar-buttonbox-container { display: none !important; }'

  # Check if the snippet already exists
  if [[ -f "$css_file" ]] && grep -q "titlebar-buttonbox-container" "$css_file" 2>/dev/null; then
    log "userChrome.css: titlebar-buttonbox-container already present — skipping"
    return 0
  fi

  # Append the CSS snippet
  if $DRY_RUN; then
    log "[dry-run] would append to $css_file:"
    log "$css_snippet"
  else
    log "Patching $css_file"
    printf '\n%s\n' "$css_snippet" >> "$css_file"
    ok "  Added titlebar-buttonbox-container to userChrome.css"
  fi
}

###############################################################################
# Main entry point
###############################################################################

noctalia_patches() {
  step "Applying Noctalia patches"
  patch_zen_userchrome
}

# Export function
export -f noctalia_patches
