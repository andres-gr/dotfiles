#!/usr/bin/env bash
# niri.sh - Niri-specific patches

# Get script directory for relative paths
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)}"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Source splash-screens for install function
# shellcheck source=scripts/patches/splash-screens.sh
source "$SCRIPT_DIR/splash-screens.sh"

###############################################################################
# Install main niri config
# This file is generated dynamically and should not be stowed
# Niri auto-reloads on config changes - no manual reload needed
###############################################################################

install_niri_config() {
  local src="$SCRIPT_DIR/data/niri-config.kdl"
  local dest="$HOME/.config/niri/config.kdl"
  local bkp_dir="$HOME/.local/share/neo-dots/niri-bkp"

  if [[ ! -f "$src" ]]; then
    warn "Source config.kdl not found at $src"
    return 1
  fi

  # Create destination directory
  mkdir -p "$(dirname "$dest")"

  # Backup existing config
  if [[ -f "$dest" ]]; then
    mkdir -p "$bkp_dir"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$dest" "$bkp_dir/config.kdl.$timestamp"
    log "Backed up existing config.kdl to $bkp_dir"
  fi

  # Copy new config
  cp "$src" "$dest"
  ok "Installed niri config.kdl (Niri will auto-reload)"
}

###############################################################################
# Configure Splash in Niri
###############################################################################

configure_splash_niri() {
  local niri_conf="$HOME/.config/niri"
  local niri_splash_conf="$niri_conf/splash.kdl"
  local niri_temp_binds="$niri_conf/splash-temp-binds.kdl"
  local splash_template="$DOTFILES_DIR/scripts/patches/data/splash-niri-config.kdl"
  local niri_main="$niri_conf/config.kdl"

  # Check for timestamp of previous splash selection
  local prev_ts
  prev_ts=$(get_selection_timestamp "splashes" "niri")

  # Extract tarball (install script handles check)
  install_splash_screens

  # Check if splashes directory exists
  local splashes_dir="$HOME/.local/assets/splashes"
  if [[ ! -d "$splashes_dir" ]]; then
    log "Splashes directory not found at $splashes_dir — skipping"
    return 0
  fi

  # Get available splashes
  local -a available_splashes
  mapfile -t available_splashes < <(find "$splashes_dir" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.webm" -o -name "*.gif" \) -printf '%f\n' | sort)

  if (( ${#available_splashes[@]} == 0 )); then
    log "No splash videos found in $splashes_dir — skipping"
    return 0
  fi

  # Create Niri config directory
  run mkdir -p "$niri_conf"

  # Already configured with splash?
  if [[ -f "$niri_splash_conf" ]] && grep -q "splash-screen-animation" "$niri_splash_conf"; then
    local msg="Splash already configured"
    [[ -n "$prev_ts" ]] && msg="$msg (last applied: $prev_ts)"

    # Ask if user wants to update
    if $INTERACTIVE && command -v gum &>/dev/null; then
      if gum confirm "$msg — update?"; then
        log "Updating splash configuration..."
        # Skip timestamp display during update
        prev_ts=""
      else
        log "$msg — skipping"
        return 0
      fi
    else
      log "$msg — skipping"
      return 0
    fi
  fi

  # Interactive selection
  local selected_splash=""
  local duration="3"
  local volume="5"

  if $INTERACTIVE; then
    log "Select splash animation to use:"
    if [[ -n "$prev_ts" ]]; then
      log "  (last applied: $prev_ts)"
    fi

    local -a choices=()
    for s in "${available_splashes[@]}"; do
      choices+=("$s")
    done

    local sel
    sel="$(interactive_select --exit "${choices[@]}")" || true

    if [[ -z "$sel" || "$sel" == "Exit" || "$sel" == "Skip" ]]; then
      log "No splash selected — skipping"
      return 0
    fi

    selected_splash="$sel"

    # Ask for duration and volume
    if command -v gum &>/dev/null; then
      duration=$(gum input --placeholder="Enter splash duration (e.g., 3s, 5s)" --value "3" || true)
      [[ -z "$duration" ]] && duration="3"

      volume=$(gum input --placeholder="Enter splash volume (0-100)" --value "5" || true)
      [[ -z "$volume" ]] && volume="5"
    else
      log "gum not found — using defaults: duration=3, volume=50"
    fi
  else
    # Non-interactive: use defaults
    selected_splash="steam-girl.mp4"
    duration="3"
    volume="5"
  fi

  $DRY_RUN && { log "[dry-run] would add splash: $selected_splash for $duration"; return 0; }

  # Verify template exists
  if [[ ! -f "$splash_template" ]]; then
    log "Splash template not found at $splash_template — skipping"
    return 0
  fi

  # Copy and inject variables
  step "Installing splash config for Niri"
  run sed -e "s|{{splash}}|$selected_splash|g" \
         -e "s|{{duration}}|$duration|g" \
         -e "s|{{volume}}|$volume|g" \
         "$splash_template" > "$niri_splash_conf"
  ok "Splash config written to $niri_splash_conf"

  # Create minimal temp binds file (valid KDL with comment)
  run printf '# Custom keybinds can be added here\n' > "$niri_temp_binds"
  ok "Temp binds file created at $niri_temp_binds"

  # Uncomment include line in main config
  if [[ -f "$niri_main" ]]; then
    run sed -i 's|^[[:space:]]*//[[:space:]]*include "splash.kdl"|include "splash.kdl"|' "$niri_main"
    ok "Splash include uncommented in config.kdl"
  fi

  # Track selection
  update_selection "splashes" "niri=$selected_splash"
  update_selection "splashes" "niri_duration=$duration"
  update_selection "splashes" "niri_volume=$volume"
}

###############################################################################
# Main entry point for Niri patches
###############################################################################

niri_patches() {
  configure_splash_niri
  install_niri_config
}
