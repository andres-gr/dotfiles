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
  local src="$SCRIPT_DIR/data/hypr_config.lua"
  local dest="$HOME/.config/hypr/hyprland.lua"
  local perf_dest="$HOME/.config/hypr/perf_mode.lua"
  local bkp_dir="$HOME/.local/share/neo-dots/hypr-bkp"

  if [[ ! -f "$src" ]]; then
    warn "Source hypr_config.lua not found at $src"
    return 1
  fi

  # Create destination directory
  mkdir -p "$(dirname "$dest")"
  mkdir -p "$(dirname "$perf_dest")"

  # Backup existing config
  if [[ -f "$dest" ]]; then
    mkdir -p "$bkp_dir"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$dest" "$bkp_dir/hyprland.lua.$timestamp"
    rm -f "$dest"
    log "Backed up existing hyprland.lua to $bkp_dir"
  fi

  # Copy new config
  cp -f "$src" "$dest"
  ok "Installed hyprland.lua"
}

###############################################################################
# Make Hyprland workspaces persistent
###############################################################################

configure_workspaces_persistent() {
  local template="$SCRIPT_DIR/data/hypr_workspaces.lua"
  local dest="$HOME/.config/hypr/workspaces.lua"

  # Skip if template doesn't exist
  if [[ ! -f "$template" ]]; then
    log "Workspace template not found at $template — skipping"
    return 0
  fi

  # Skip if dest already exists and is fully configured
  if [[ -f "$dest" ]]; then
    if grep -q 'hl.workspace_rule' "$dest" 2>/dev/null; then
      log "Workspaces already configured — skipping"
      return 0
    fi
  fi

  if $DRY_RUN; then
    log "[dry-run] would generate workspaces.lua from template"
    return 0
  fi

  # Try to get monitor names from hyprctl (requires Hyprland running)
  local main_monitor=""
  local secondary_monitor=""

  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    # Hyprland is running — get monitor descriptions
    local monitors
    monitors=$(hyprctl monitors -j 2>/dev/null) || true
    if [[ -n "$monitors" && "$monitors" != "null" ]]; then
      # Use description field (matches old config format)
      main_monitor=$(echo "$monitors" | jq -r '.[0].description // empty' 2>/dev/null) || true
      secondary_monitor=$(echo "$monitors" | jq -r '.[1].description // empty' 2>/dev/null) || true
    fi
  fi

  # Get monitor names from environment if hyprctl failed
  [[ -z "$main_monitor" ]] && main_monitor="${HL_MAIN_MONITOR:-}"
  [[ -z "$secondary_monitor" ]] && secondary_monitor="${HL_SECONDARY_MONITOR:-}"

  # Warn if no monitors configured
  if [[ -z "$main_monitor" || -z "$secondary_monitor" ]]; then
    warn "Could not determine monitor names — using placeholders in workspaces.lua"
    warn "Set HL_MAIN_MONITOR and HL_SECONDARY_MONITOR env vars or run Hyprland first"
    main_monitor="{{main_monitor}}"
    secondary_monitor="{{secondary_monitor}}"
  fi

  # Generate workspaces.lua from template
  step "Generating workspaces.lua"
  sed -e "s#{{main_monitor}}#${main_monitor}#g" \
    -e "s#{{secondary_monitor}}#${secondary_monitor}#g" \
    "$template" > "$dest"
  ok "Generated $dest with monitor: $main_monitor, $secondary_monitor"
}

###############################################################################
# Install monitors.lua from template
###############################################################################

configure_monitors_lua() {
  local template="$SCRIPT_DIR/data/hypr_monitors.lua"
  local dest="$HOME/.config/hypr/monitors.lua"

  # Skip if template doesn't exist
  if [[ ! -f "$template" ]]; then
    log "Monitors template not found at $template — skipping"
    return 0
  fi

  # Skip if dest already exists and is fully configured
  if [[ -f "$dest" ]]; then
    if grep -q 'hl.monitor' "$dest" 2>/dev/null; then
      log "Monitors already configured — skipping"
      return 0
    fi
  fi

  if $DRY_RUN; then
    log "[dry-run] would generate monitors.lua from template"
    return 0
  fi

  # Try to get monitor descriptions from hyprctl (requires Hyprland running)
  local main_monitor=""
  local secondary_monitor=""

  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    local monitors
    monitors=$(hyprctl monitors -j 2>/dev/null) || true
    if [[ -n "$monitors" && "$monitors" != "null" ]]; then
      main_monitor=$(echo "$monitors" | jq -r '.[0].description // empty' 2>/dev/null) || true
      secondary_monitor=$(echo "$monitors" | jq -r '.[1].description // empty' 2>/dev/null) || true
    fi
  fi

  # Fall back to env vars
  [[ -z "$main_monitor" ]] && main_monitor="${HL_MAIN_MONITOR:-}"
  [[ -z "$secondary_monitor" ]] && secondary_monitor="${HL_SECONDARY_MONITOR:-}"

  # Warn and use placeholders if unknown
  if [[ -z "$main_monitor" || -z "$secondary_monitor" ]]; then
    warn "Could not determine monitor descriptions — using placeholders in monitors.lua"
    warn "Set HL_MAIN_MONITOR and HL_SECONDARY_MONITOR env vars or run Hyprland first"
    main_monitor="{{main_monitor}}"
    secondary_monitor="{{secondary_monitor}}"
  fi

  # Generate monitors.lua from template
  step "Generating monitors.lua"
  sed -e "s#{{main_monitor}}#${main_monitor}#g" \
    -e "s#{{secondary_monitor}}#${secondary_monitor}#g" \
    "$template" > "$dest"
  ok "Generated $dest with monitor: $main_monitor, $secondary_monitor"
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
  local hypr_splash_conf="$hypr_conf/splash.lua"
  local hypr_temp_binds="$hypr_conf/splash_temp_binds.lua"
  local splash_template="$DOTFILES_DIR/scripts/patches/data/splash_hypr_config.lua"
  local hypr_main="$hypr_conf/hyprland.lua"

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

  # Create minimal temp binds file (valid Lua with comment)
  run printf '%s\n' '-- Custom keybinds can be added here' > "$hypr_temp_binds"
  ok "Temp binds file created at $hypr_temp_binds"

  # Track selection
  update_selection "splashes" "hyprland=$selected_splash"
  update_selection "splashes" "hyprland_duration=$duration"
  update_selection "splashes" "hyprland_volume=$volume"
}

# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  configure_monitors_lua
  configure_splash_hyprland
  configure_workspaces_persistent
  install_hymission
  install_hyprland_config
  reload_hyprland
}
