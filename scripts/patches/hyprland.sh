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
# Configure Steam Splash in Hyprland
###############################################################################

configure_steam_splash_hyprland() {
  local hypr_root="$HOME/.config/hypr/modules/root.conf"

  # Extract tarball (install script handles check)
  install_splash_screens

  # Check if symlink and resolve to actual file
  if [[ -L "$hypr_root" ]]; then
    local real_root
    real_root=$(readlink -f "$hypr_root")
    hypr_root="$real_root"
  fi

  # Already configured?
  [[ -f "$hypr_root" ]] && grep -q "splash-screen-animation" "$hypr_root" && return 0

  $DRY_RUN && { log "[dry-run] would add splash exec-once"; return 0; }

  step "Adding splash to Hyprland config"
  run sed -i '/^exec-once = dbus-update/a exec-once = ~/.local/bin/splash-screen-animation' "$hypr_root"
  ok "Splash added to root.conf"
}

###############################################################################
# Main entry point for Hyprland patches
###############################################################################

hyprland_patches() {
  configure_steam_splash_hyprland
  configure_workspaces_persistent
  install_hymission
  install_hyprland_config
  reload_hyprland
}
