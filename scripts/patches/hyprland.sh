#!/usr/bin/env bash
# hyprland.sh - Hyprland-specific patches

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

  # Check if already has persistent:true
  if grep -q 'persistent:true' "$ws_conf" 2>/dev/null; then
    log "Workspaces already persistent — skipping"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would add persistent:true to workspace lines"
    return 0
  fi

  # Add ,persistent:true to each workspace= line
  local tmp
  tmp=$(mktemp)
  while IFS= read -r line; do
    if [[ "$line" =~ ^workspace= ]]; then
      # Add ,persistent:true at end if not present
      if [[ "$line" != *persistent:true* ]]; then
        line="$line,persistent:true"
      fi
    fi
    printf '%s\n' "$line"
  done < "$ws_conf" > "$tmp"

  run mv "$tmp" "$ws_conf"
  ok "Added persistent:true to workspaces"
}

###############################################################################
# Install hyprtasking plugin
###############################################################################

install_hyprtasking() {
  # Check if Hyprland plugin manager is available
  if ! command -v hyprpm &>/dev/null; then
    log "hyprpm not found — skipping hyprtasking install"
    return 0
  fi

  # Check if already installed
  local plugins
  plugins=$(hyprpm list 2>/dev/null) || true
  if echo "$plugins" | grep -qi "hyprtasking"; then
    log "hyprtasking already installed"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would install hyprtasking plugin"
    return 0
  fi

  step "Installing hyprtasking plugin"

  # Add the plugin (this may ask for sudo password on first run)
  run hyprpm add https://github.com/raybbian/hyprtasking || {
    warn "Failed to add hyprtasking — skipping"
    return 0
  }

  # Enable the plugin
  run hyprpm enable hyprtasking || {
    warn "Failed to enable hyprtasking — skipping"
    return 0
  }

  ok "hyprtasking installed and enabled"
}

###############################################################################
# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  configure_workspaces_persistent
  install_hyprland_config
  install_hyprtasking
  reload_hyprland
}
