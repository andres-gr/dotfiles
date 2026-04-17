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
  local niri_root="$HOME/.config/niri/modules/root.kdl"
  local splashes_dir="$HOME/.local/assets/splashes"

  # Extract tarball (install script handles check)
  install_splash_screens

  # Check if splashes directory exists
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

  # Check if Niri config directory exists
  mkdir -p "$HOME/.config/niri/modules"

  # Already configured with splash?
  if [[ -f "$niri_root" ]] && grep -q "splash-screen-animation" "$niri_root"; then
    log "Splash already configured — skipping"
    return 0
  fi

  # Interactive selection
  if $INTERACTIVE; then
    log "Select splash animation to use:"
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

    local selected_splash="$sel"

    # Ask for duration
    local duration="3"
    if command -v gum &>/dev/null; then
      duration=$(gum input --placeholder="Enter splash duration (e.g., 3s, 5s)" --value "3" || true)
      [[ -z "$duration" ]] && duration="3"
    else
      log "gum not found — using default duration: 3s"
    fi

    $DRY_RUN && { log "[dry-run] would add splash: $selected_splash for $duration"; return 0; }

    step "Adding splash to Niri config"
    run sed -i '/^spawn-at-startup "dbus-update-activation-environment/a spawn-at-startup "STARTUP_SPLASH='"$selected_splash"'" "STARTUP_SPLASH_DURATION='"$duration"'" ~/.local/bin/splash-screen-animation' "$niri_root"
    ok "Splash added to root.kdl"
  else
    # Non-interactive: use default
    $DRY_RUN && { log "[dry-run] would add splash exec-once"; return 0; }

    step "Adding splash to Niri config"
    run sed -i '/^spawn-at-startup "dbus-update-activation-environment/a spawn-at-startup "STARTUP_SPLASH=steam-girl.mp4" "STARTUP_SPLASH_DURATION=3" ~/.local/bin/splash-screen-animation' "$niri_root"
    ok "Splash added to root.kdl"
  fi
}

###############################################################################
# Main entry point for Niri patches
###############################################################################

niri_patches() {
  configure_splash_niri
  install_niri_config
}
