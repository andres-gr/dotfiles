#!/usr/bin/env bash
# hyprland.sh - Hyprland-specific patches

# Get script directory for relative paths
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)}"

# Define DOTFILES_DIR if not set (for standalone sourcing)
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Source splash-screens for install function
# shellcheck source=scripts/patches/splash-screens.sh
source "$SCRIPT_DIR/splash-screens.sh"

###############################################################################
# Reload Hyprland configuration
# Only runs if Hyprland session is active
###############################################################################

reload_hyprland() {
  # Check if Hyprland session is active
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    log "Hyprland session active — reloading config"
    run hyprctl reload 2>/dev/null || warn "hyprctl reload failed (non-fatal)"
  else
    log "No active Hyprland session — skipping reload"
  fi
}

###############################################################################
# Install main Hyprland config
###############################################################################

install_hyprland_config() {
  local src="$SCRIPT_DIR/data/hypr-config.conf"
  local dest="$HOME/.config/hypr/hyprland.conf"
  local bkp_dir="$HOME/.local/share/neo-dots/hypr-bkp"

  if [[ ! -f "$src" ]]; then
    warn "Source hypr-config.conf not found at $src"
    return 1
  fi

  # Create destination directory
  mkdir -p "$(dirname "$dest")"

  # Backup existing config
  if [[ -f "$dest" ]]; then
    mkdir -p "$bkp_dir"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$dest" "$bkp_dir/hyprland.conf.$timestamp"
    rm -f "$dest"
    log "Backed up existing hyprland.conf to $bkp_dir"
  fi

  # Copy new config
  cp -f "$src" "$dest"
  ok "Installed hyprland.conf"
}

###############################################################################
# Make Hyprland workspaces persistent
###############################################################################

configure_workspaces_persistent() {
  local ws_conf="$HOME/.config/hypr/workspaces.conf"

  # Skip if file doesn't exist
  if [[ ! -f "$ws_conf" ]]; then
    log "Hyprland workspaces.conf not found — skipping"
    return 0
  fi

  # Check if already has defaultName (implies fully configured)
  if grep -q 'defaultName:' "$ws_conf" 2>/dev/null; then
    log "Workspaces already have defaultName — skipping"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would add persistent:true and defaultName to workspace lines"
    return 0
  fi

  # Add ,persistent:true and defaultName to each workspace= line
  local tmp
  tmp=$(mktemp)
  while IFS= read -r line; do
    if [[ "$line" =~ ^workspace= ]]; then
      # Add ,persistent:true if not present
      if [[ "$line" != *persistent:true* ]]; then
        line="$line,persistent:true"
      fi

      # Extract workspace number
      if [[ "$line" =~ ^workspace=([0-9]+) ]]; then
        local ws_num="${BASH_REMATCH[1]}"
        local defaultName=""

        # First 4 workspaces (ws 1-4): prim1-prim4 (main monitor)
        # Last 4 workspaces (ws 5-8): sec1-sec4 (secondary monitor)
        if (( ws_num <= 4 )); then
          defaultName="prim$ws_num"
        elif (( ws_num >= 5 && ws_num <= 8 )); then
          local sec_num=$(( ws_num - 4 ))
          defaultName="sec$sec_num"
        fi

        # Add defaultName if applicable
        if [[ -n "$defaultName" && "$line" != *defaultName:* ]]; then
          line="$line,defaultName:$defaultName"
        fi
      fi
    fi
    printf '%s\n' "$line"
  done < "$ws_conf" > "$tmp"

  run mv "$tmp" "$ws_conf"
  ok "Added persistent:true and defaultName to workspaces"
}

###############################################################################
# Install hymission plugin
###############################################################################

install_hymission() {
  # Check if Hyprland plugin manager is available
  if ! command -v hyprpm &>/dev/null; then
    log "hyprpm not found — skipping plugins install"
    return 0
  fi

  # Check if already installed
  local plugins
  plugins=$(hyprpm list 2>/dev/null) || true
  if echo "$plugins" | grep -qi "hymission"; then
    log "hymission already installed"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would install hymission plugin"
    return 0
  fi

  step "Installing hymission plugin"

  # Add the plugin (this may ask for sudo password on first run)
  run hyprpm add https://github.com/gfhdhytghd/hymission || {
    warn "Failed to add hymission — skipping"
    return 0
  }

  # Enable the plugin
  run hyprpm enable hymission || {
    warn "Failed to enable hymission — skipping"
    return 0
  }

  ok "hymission installed and enabled"
}

###############################################################################
# Configure Splash in Hyprland
###############################################################################

configure_splash_hyprland() {
  local hypr_conf="$HOME/.config/hypr"
  local hypr_splash_conf="$hypr_conf/splash.conf"
  local hypr_temp_binds="$hypr_conf/splash-temp-binds.conf"
  local splash_template="$DOTFILES_DIR/scripts/patches/data/splash-hypr-config.conf"
  local hypr_main="$hypr_conf/hyprland.conf"

  # Check for timestamp of previous splash selection
  local prev_ts
  prev_ts=$(get_selection_timestamp "splashes" "hyprland")

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

  # Already configured with splash?
  if [[ -f "$hypr_splash_conf" ]] && grep -q "splash-screen-animation" "$hypr_splash_conf"; then
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
  step "Installing splash config for Hyprland"
  run mkdir -p "$hypr_conf"
  run sed -e "s|{{splash}}|$selected_splash|g" \
         -e "s|{{duration}}|$duration|g" \
         -e "s|{{volume}}|$volume|g" \
         "$splash_template" > "$hypr_splash_conf"
  ok "Splash config written to $hypr_splash_conf"

  # Create minimal temp binds file (valid KDL with comment)
  run printf '// Custom keybinds can be added here\n' > "$hypr_temp_binds"
  ok "Temp binds file created at $hypr_temp_binds"

  # Uncomment source line in main config
  if [[ -f "$hypr_main" ]]; then
    run sed -i 's|^[[:space:]]*#[[:space:]]*source = ./splash.conf|source = ./splash.conf|' "$hypr_main"
    ok "Splash source uncommented in hyprland.conf"
  fi

  # Track selection
  update_selection "splashes" "hyprland=$selected_splash"
  update_selection "splashes" "hyprland_duration=$duration"
  update_selection "splashes" "hyprland_volume=$volume"
}

###############################################################################
# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  configure_splash_hyprland
  configure_workspaces_persistent
  install_hymission
  install_hyprland_config
  reload_hyprland
}
