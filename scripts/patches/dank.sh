#!/usr/bin/env bash
# dank.sh - Dank Material Shell patches
# Can run alongside Hyprland or Niri

###############################################################################
# Reload DMS (Dank Material Shell)
# Only runs if DMS is installed/running
###############################################################################

reload_dms() {
  if command -v dmsctl &>/dev/null; then
    log "Reloading DMS (Dank Material Shell)"
    dmsctl restart 2>/dev/null || warn "dmsctl restart failed (non-fatal)"
  else
    log "DMS not installed — skipping reload"
  fi
}

###############################################################################
# Main entry point for DMS patches
###############################################################################

dank_patches() {
  reload_dms
}

# Export function
export -f dank_patches
