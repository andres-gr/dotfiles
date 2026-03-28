#!/usr/bin/env bash
# niri.sh - Niri-specific patches
# Placeholder for future Niri reload/config logic

###############################################################################
# Reload Niri configuration
# Only runs if Niri session is active
###############################################################################

reload_niri() {
  # Niri doesn't have a reload command like Hyprland
  # You typically need to restart the compositor
  log "Niri reload: restart the compositor to apply config changes"
  # TODO: Add Niri-specific reload mechanism if available
}

###############################################################################
# Main entry point for Niri patches
###############################################################################

niri_patches() {
  reload_niri
}
