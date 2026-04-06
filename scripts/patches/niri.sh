#!/usr/bin/env bash
# niri.sh - Niri-specific patches

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# Main entry point for Niri patches
###############################################################################

niri_patches() {
  install_niri_config
}
