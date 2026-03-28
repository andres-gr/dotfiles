#!/usr/bin/env bash
# hyprland.sh - Hyprland-specific patches
# Reloads Hyprland configuration and related components

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
# Reload waybar
# Only runs if waybar is running
###############################################################################

reload_waybar() {
  if command -v pkill &>/dev/null; then
    pkill -SIGUSR2 waybar 2>/dev/null || true
    log "Sent reload signal to waybar"
  fi
}

###############################################################################
# Remind about hyprlock preset
###############################################################################

remind_hyprlock_preset() {
  # Check if arch-hyde was stowed
  local hyprlock_preset="$HOME/.config/hypr/hyprlock/neo.conf"
  if [[ -f "$hyprlock_preset" ]]; then
    log "Hyprlock preset 'neo' available at: $hyprlock_preset"
    log "  theme.conf already points to it — active on next lock."
    log "  To switch preset: edit ~/.config/hypr/hyprlock/theme.conf"
  fi
}

###############################################################################
# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  reload_hyprland
  reload_waybar
  remind_hyprlock_preset
}
