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
# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  configure_workspaces_persistent
  reload_hyprland
}
