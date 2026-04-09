#!/usr/bin/env bash
# common.sh - Generic patches for Arch Linux
# Called from post_install_task in install.sh
# These patches run regardless of which WM/DE is used

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# TPM installation (tmux plugins)
###############################################################################

install_tpm() {
  if command -v tmux &>/dev/null; then
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
      log "Installing TPM (Tmux Plugin Manager)"
      run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
      log "TPM already installed"
    fi
  fi
}

###############################################################################
# Ghostty misc-config
# Creates platform-specific overrides for Ghostty terminal
###############################################################################

install_ghostty_misc_config() {
  local ghostty_config_dir="$HOME/.config/ghostty"
  local misc_config="$ghostty_config_dir/misc-config"

  if [[ ! -d "$ghostty_config_dir" ]]; then
    log "Ghostty config directory not found — skipping misc-config"
    return
  fi

  # Detect if we should use Arch or macOS config
  local is_arch=false
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    is_arch=true
  fi

  if $is_arch; then
    log "Creating Ghostty misc overrides: $misc_config"
    run mkdir -p "$ghostty_config_dir"
    if $DRY_RUN; then
      log "[dry-run] would write to $misc_config:"
      log "  background-blur = 0"
      log "  background-opacity = 1"
      log "  font-size = 11"
      log "  gtk-single-instance = true"
      log "  gtk-titlebar = false"
      log "  keybind = ctrl+enter=unbind"
      log "  keybind = shift+enter=text:\n"
      log "  mouse-scroll-multiplier = 0.5"
      log "  shell-integration = detect"
      log "  shell-integration-features = cursor,sudo,title,no-cursor"
      log "  window-decoration = false"
    else
      cat > "$misc_config" <<'EOF'
background-blur = 0
background-opacity = 1
font-size = 11
gtk-single-instance = true
gtk-titlebar = false
keybind = ctrl+enter=unbind
keybind = shift+enter=text:\n
mouse-scroll-multiplier = 0.5
shell-integration = detect
shell-integration-features = cursor,sudo,title,no-cursor
window-decoration = false
EOF
      ok "  wrote $misc_config"
    fi
  else
    # For macOS or other systems, create empty file if it doesn't exist
    run mkdir -p "$ghostty_config_dir"
    if [[ ! -e "$misc_config" ]]; then
      if $DRY_RUN; then
        log "[dry-run] would create empty file at $misc_config:"
        log "  touch $misc_config"
      else
        log "Creating empty Ghostty misc-config for macOS"
        run touch "$misc_config"
      fi
    fi
  fi
}

###############################################################################
# arch-patches dconf profiles
# Loads dconf profiles from dotfiles/arch-patches/dconf/
###############################################################################

apply_arch_patch_dconf() {
  local src_dir="$DOTFILES_DIR/arch-patches/dconf"
  [[ -d "$src_dir" ]] || return 0

  # Map: filename stem -> dconf base path
  declare -A dconf_paths=(
    [cavasik]="/io/github/TheWisker/Cavasik/"
  )

  local -a files
  mapfile -t files < <(find "$src_dir" -maxdepth 1 -name '*.dconf' -printf '%f\n')

  (( ${#files[@]} == 0 )) && return 0

  step "Applying arch-patches dconf profiles"
  for f in "${files[@]}"; do
    local stem="${f%.dconf}"
    local path="${dconf_paths[$stem]:-}"
    if [[ -z "$path" ]]; then
      warn "  $f: no dconf path mapping defined — skipping"
      continue
    fi
    if $DRY_RUN; then
      log "[dry-run] would apply $f → dconf $path"
      continue
    fi
    log "  Applying $f → dconf $path"
    dconf load "$path" < "$src_dir/$f"
    ok "  $stem dconf profile applied"
  done
}

###############################################################################
# arch-patches systemd services
# Copies service files from dotfiles/arch-patches/systemctl/
###############################################################################

install_arch_patch_services() {
  local src_dir="$DOTFILES_DIR/arch-patches/systemctl"
  [[ -d "$src_dir" ]] || return 0

  local -a services
  mapfile -t services < <(find "$src_dir" -maxdepth 1 -name '*.service' -printf '%f\n')

  if (( ${#services[@]} == 0 )); then
    log "arch-patches/systemctl: no service files found — skipping"
    return 0
  fi

  step "Installing arch-patches systemd services"
  for svc in "${services[@]}"; do
    local dest="/etc/systemd/system/$svc"
    if systemctl is-enabled "$svc" &>/dev/null; then
      log "  $svc: already enabled — skipping"
      continue
    fi
    log "  Installing $svc → $dest"
    run sudo cp "$src_dir/$svc" "$dest"
    run sudo systemctl daemon-reload
    if systemctl is-enabled "$svc" &>/dev/null; then
      ok "  $svc enabled"
    else
      run sudo systemctl enable "$svc" 2>/dev/null || true
      if systemctl is-enabled "$svc" &>/dev/null; then
        ok "  $svc enabled"
      else
        warn "  $svc: enable failed (may need manual enable)"
      fi
    fi
  done
}

###############################################################################
# Main entry point for common patches
###############################################################################

common_patches() {
  install_tpm
  install_ghostty_misc_config
  apply_arch_patch_dconf
  install_arch_patch_services
  install_pam_configs
  install_systemd_scripts
}

###############################################################################
# PAM configuration patches
# Installs greetd PAM configs if greetd is detected
###############################################################################

install_pam_configs() {
  # Only run on Arch/CachyOS
  [[ "$OS" != "arch" && "$OS" != "cachyos" ]] && return 0

  # Check if greetd is installed
  if ! $GREETD_DETECTED; then
    log "greetd not detected — skipping PAM configs"
    return 0
  fi

  local src_dir="$DOTFILES_DIR/arch-patches/pam.d"
  [[ -d "$src_dir" ]] || { log "arch-patches/pam.d not found"; return 0; }

  local -a pam_files
  mapfile -t pam_files < <(find "$src_dir" -maxdepth 1 -type f -printf '%f\n')

  if (( ${#pam_files[@]} == 0 )); then
    log "arch-patches/pam.d: no files found — skipping"
    return 0
  fi

  step "Installing PAM configurations for greetd"

  local bkp_root="$HOME/.local/share/neo-dots/pam-bkp"
  run mkdir -p "$bkp_root"

  for pam in "${pam_files[@]}"; do
    local dest="/etc/pam.d/$pam"

    # Backup existing file
    if [[ -f "$dest" ]]; then
      local bkp="$bkp_root/${pam}.bak"
      log "  Backing up $dest → $bkp"
      run sudo cp "$dest" "$bkp"
    fi

    log "  Installing $pam → $dest"
    run sudo cp "$src_dir/$pam" "$dest"
    ok "  $pam installed"
  done
}

###############################################################################
# systemd scripts installation
# Installs scripts to /lib/systemd/ (e.g., system-sleep, system-rdsleep, etc.)
###############################################################################

install_systemd_scripts() {
  # Only run on Arch/CachyOS
  [[ "$OS" != "arch" && "$OS" != "cachyos" ]] && return 0

  local src_base="$DOTFILES_DIR/arch-patches/systemd"
  [[ -d "$src_base" ]] || return 0

  # Find all subdirectories (like system-sleep, system-rdsleep, etc.)
  local -a subdirs
  mapfile -t subdirs < <(find "$src_base" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

  if (( ${#subdirs[@]} == 0 )); then
    log "arch-patches/systemd: no subdirectories found — skipping"
    return 0
  fi

  step "Installing systemd scripts"

  local bkp_root="$HOME/.local/share/neo-dots/systemd-bkp"
  run mkdir -p "$bkp_root"

  for subdir in "${subdirs[@]}"; do
    local src_dir="$src_base/$subdir"
    local dest_dir="/lib/systemd/$subdir"

    # Create destination directory if it doesn't exist
    run sudo mkdir -p "$dest_dir"

    # Find all scripts in this subdirectory
    local -a scripts
    mapfile -t scripts < <(find "$src_dir" -maxdepth 1 -type f -printf '%f\n')

    for script in "${scripts[@]}"; do
      local src_file="$src_dir/$script"
      local dest_file="$dest_dir/$script"

      # Backup existing script
      if [[ -f "$dest_file" ]]; then
        local bkp="$bkp_root/${subdir}_${script}.bak"
        log "  Backing up $dest_file → $bkp"
        run sudo cp "$dest_file" "$bkp"
      fi

      # Copy script
      log "  Installing $script → $dest_file"
      run sudo cp "$src_file" "$dest_file"

      # Make executable
      run sudo chmod +x "$dest_file"
      ok "  $script installed and executable"
    done
  done
}

###############################################################################
# Yazi plugins installation
# Install/update yazi plugins if yazi is available
###############################################################################

install_yazi_plugins() {
  # Check if yazi is installed
  if ! command -v ya &>/dev/null; then
    log "Yazi not installed — skipping plugins"
    return 0
  fi

  local -a plugins=(
    "boydaihungst/mediainfo"
    "lpnh/fr"
    "yazi-rs/plugins:git"
  )

  log "Checking yazi plugins..."

  # Get list of installed plugins
  local installed_plugins
  installed_plugins=$(ya pkg list 2>/dev/null || echo "")

  local -a to_install=()
  local -a to_upgrade=()

  for plugin in "${plugins[@]}"; do
    # Extract just the plugin identifier for checking
    local plugin_name="${plugin%%:*}"  # Remove :git suffix if present
    plugin_name="${plugin_name##*/}"    # Remove owner/ prefix

    if echo "$installed_plugins" | grep -qw "$plugin_name"; then
      to_upgrade+=("$plugin")
    else
      to_install+=("$plugin")
    fi
  done

  # Upgrade existing plugins
  if (( ${#to_upgrade[@]} > 0 )); then
    log "Upgrading ${#to_upgrade[@]} yazi plugin(s)..."
    if $DRY_RUN; then
      log "[dry-run] would run: ya pkg upgrade"
    else
      if ya pkg upgrade 2>/dev/null; then
        ok "Upgraded yazi plugins"
      else
        warn "Some yazi plugins failed to upgrade"
      fi
    fi
  fi

  # Install missing plugins
  if (( ${#to_install[@]} > 0 )); then
    log "Installing ${#to_install[@]} new yazi plugin(s)..."
    for plugin in "${to_install[@]}"; do
      if $DRY_RUN; then
        log "[dry-run] would run: ya pkg add $plugin"
      else
        if ya pkg add "$plugin" 2>/dev/null; then
          log "  Installed: $plugin"
        else
          warn "  Failed to install: $plugin"
        fi
      fi
    done
    ok "Installed yazi plugins"
  fi

  if (( ${#to_install[@]} == 0 )) && (( ${#to_upgrade[@]} == 0 )); then
    log "All yazi plugins already installed"
  fi
}

###############################################################################
# SDDM theme settings update
# Update SDDM theme settings if the theme is installed
###############################################################################

update_sddm_theme() {
  local src="$SCRIPT_DIR/data/sddm-settings.conf"
  local dest="/usr/share/sddm/themes/sddm-noctalia-theme/Commons/Settings.conf"
  local bkp_dir="$HOME/.local/share/neo-dots/sddm-bkp"

  # Check if source file exists
  if [[ ! -f "$src" ]]; then
    warn "SDDM settings source not found at $src"
    return 1
  fi

  # Check if target directory/theme exists
  if [[ ! -d "/usr/share/sddm/themes/sddm-noctalia-theme" ]]; then
    log "SDDM Noctalia theme not installed — skipping"
    return 0
  fi

  # Check if target file exists
  if [[ ! -f "$dest" ]]; then
    log "SDDM Settings.conf not found at $dest — skipping"
    return 0
  fi

  # Initialize bg.png if it doesn't exist (do this first, before early return)
  local wallpaper="/usr/share/sddm/themes/sddm-noctalia-theme/Assets/Wallpaper/bg.png"
  local default_wallpaper="/usr/share/sddm/themes/sddm-noctalia-theme/Assets/Wallpaper/noctalia.png"
  if [[ ! -f "$wallpaper" ]] && [[ -f "$default_wallpaper" ]]; then
    run sudo cp "$default_wallpaper" "$wallpaper"
    log "Initialized bg.png from default wallpaper"
  fi

  # Ensure wallpaper directory and file are writable for user updates (always run)
  local wallpaper_dir="$(dirname "$wallpaper")"
  if [[ -d "$wallpaper_dir" ]]; then
    run sudo chmod 777 "$wallpaper_dir"
  fi
  if [[ -f "$wallpaper" ]]; then
    run sudo chmod 666 "$wallpaper"
  fi

  # Check if already up to date (compare content)
  if cmp -s "$src" "$dest"; then
    log "SDDM Settings.conf already up to date — skipping"
    return 0
  fi

  # Backup existing file
  mkdir -p "$bkp_dir"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  run sudo cp "$dest" "$bkp_dir/Settings.conf.$timestamp"
  log "Backed up Settings.conf to $bkp_dir"

  # Copy new settings
  if $DRY_RUN; then
    log "[dry-run] would copy $src to $dest"
  else
    run sudo cp "$src" "$dest"
    # Make writable for user (Noctalia shell hook needs to update later)
    run sudo chmod 666 "$dest"
    ok "Updated SDDM theme Settings.conf"
  fi
}

###############################################################################
# SDDM X11 single display configuration
# Configure SDDM to use X11 backend and show greeter only on primary display
###############################################################################

install_sddm_x11_config() {
  local sddm_conf_dir="/etc/sddm.conf.d"
  local sddm_scripts_dir="/etc/sddm/scripts"
  local display_setup_script="$sddm_scripts_dir/display-setup.sh"
  local bkp_dir="$HOME/.local/share/neo-dots/sddm-bkp"

  # Check if SDDM is installed
  if ! command -v sddm &>/dev/null; then
    log "SDDM not installed — skipping X11 config"
    return 0
  fi

  # Detect primary monitor from niri config at patch time
  # This runs while niri IS running, so we can query it directly
  local primary_model=""
  local primary_connector=""
  local primary_mode=""
  local primary_rate=""
  local niri_outputs="$HOME/.config/niri/modules/outputs.kdl"

  if [[ -f "$niri_outputs" ]]; then
    # Extract the monitor name at position x=0 y=0 (primary)
    primary_model=$(awk -F'"' '/output /{name=$2} /position x=0 y=0/{print name}' "$niri_outputs" 2>/dev/null || true)
    log "Primary monitor model: $primary_model"

    # Query niri for connector name
    if [[ -n "$primary_model" ]] && command -v niri &>/dev/null; then
      primary_connector=$(niri msg outputs 2>/dev/null | grep -F "$primary_model" | grep -oP '\(\K[^)]+' || true)
      log "Primary connector: $primary_connector"
    fi

    # Extract mode from niri config (format: "2560x1440@120.000")
    if [[ -n "$primary_model" ]]; then
      primary_mode=$(awk -v model="$primary_model" '
        /^output/ { in_output=0 }
        $0 ~ model { in_output=1 }
        /^}/ { in_output=0 }
        /mode/ && in_output { gsub(/"/, ""); print $2; exit }
      ' "$niri_outputs" 2>/dev/null || true)
      # Parse mode into resolution and rate
      primary_rate=$(echo "$primary_mode" | grep -oP '@\K[0-9.]+' || true)
      primary_rate=${primary_rate%.*}
      log "Primary mode: $primary_mode (rate: $primary_rate Hz)"
    fi
  fi

  # Fallback: detect from xrandr if niri detection failed
  if [[ -z "$primary_connector" ]] && command -v xrandr &>/dev/null; then
    primary_connector=$(xrandr --list 2>/dev/null | grep -w connected | head -1 | awk '{print $1}' || true)
    log "Fallback: using first connected display: $primary_connector"
  fi

  # Fallback for rate if not detected
  if [[ -z "$primary_rate" ]]; then
    primary_rate="60"
  fi

  # Step 1: Configure SDDM to use X11 backend with proper server arguments
  # Xinerama is critical for multi-monitor handling in X11
  local sddm_conf="$sddm_conf_dir/10-x11.conf"

  if $DRY_RUN; then
    log "[dry-run] would create SDDM X11 config at $sddm_conf"
  else
    run sudo mkdir -p "$sddm_conf_dir"
    run sudo tee "$sddm_conf" >/dev/null << 'EOF'
[General]
DisplayServer=x11

[X11]
ServerArguments=-nolisten tcp -background none +xinerama +extension RANDR +extension RENDER +extension GLX
EOF
    ok "Configured SDDM X11 with Xinerama support"
  fi

  # Step 2: Create monitor-specific config to use DisplayCommand
  # DisplayCommand runs after X server is fully started, more reliable than Xsetup
  local monitor_conf="$sddm_conf_dir/20-monitor.conf"

  if $DRY_RUN; then
    log "[dry-run] would create monitor config at $monitor_conf"
  else
    run sudo tee "$monitor_conf" >/dev/null << EOF
[X11]
DisplayCommand=$display_setup_script
EOF
    ok "Configured DisplayCommand for single display"
  fi

# Step 3: Create display-setup.sh script
  # This script configures displays to show greeter only on primary monitor
  # Uses a separate config file for the connector value

  # Create the config file with the primary connector and mode
  local connector_config="/etc/sddm/scripts/primary-connector.conf"

  if $DRY_RUN; then
    log "[dry-run] would create connector config at $connector_config"
  else
    # Create scripts directory first
    run sudo mkdir -p "$(dirname "$connector_config")"
    run sudo tee "$connector_config" >/dev/null << EOF
PRIMARY_CONNECTOR=$primary_connector
PRIMARY_RATE=$primary_rate
EOF
    log "Created connector config: $primary_connector @ ${primary_rate}Hz"
  fi

  # Generate the display-setup.sh script that reads from config
  local script_content
  script_content=$(cat << 'SCRIPTEOF'
#!/bin/sh
# display-setup.sh - SDDM display configuration
# Configures greeter to appear only on primary monitor with correct mode
# Reads connector and rate from config file

set -e

CONFIG_FILE='/etc/sddm/scripts/primary-connector.conf'
LOG_FILE='/etc/sddm/scripts/display-setup.log'

# Read connector and rate from config file
if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
fi

# Default rate if not set
PRIMARY_RATE=${PRIMARY_RATE:-60}

# Create log file if it doesn't exist
touch "$LOG_FILE" 2>/dev/null || true

log_msg() {
  date_str=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$date_str] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_msg 'SDDM display-setup.sh started'
log_msg "Primary connector: $PRIMARY_CONNECTOR, rate: ${PRIMARY_RATE}Hz"

# Check if xrandr is available
if ! command -v xrandr >/dev/null 2>&1; then
  log_msg "ERROR: xrandr not found"
  exit 1
fi

# Enable primary display with explicit mode and rate
# First try the configured connector, then fallback to position-based detection
PRIMARY_FOUND=""

if [ -n "$PRIMARY_CONNECTOR" ] && xrandr | grep "^$PRIMARY_CONNECTOR " >/dev/null 2>&1; then
  PRIMARY_FOUND="$PRIMARY_CONNECTOR"
  log_msg "Found primary connector: $PRIMARY_CONNECTOR"
fi

# Fallback: find display at position x=0 (primary position)
if [ -z "$PRIMARY_FOUND" ]; then
  PRIMARY_FOUND=$(xrandr | grep " connected " | awk '{if ($3 ~ /^[0-9]+x[0-9]+[+]0[+]0$/) print $1}' | head -1)
  if [ -n "$PRIMARY_FOUND" ]; then
    log_msg "Found primary by position: $PRIMARY_FOUND"
  fi
fi

# Fallback: use first connected display
if [ -z "$PRIMARY_FOUND" ]; then
  PRIMARY_FOUND=$(xrandr | grep " connected " | head -1 | awk '{print $1}')
  log_msg "Using first connected display: $PRIMARY_FOUND"
fi

# Now configure the primary display
if [ -n "$PRIMARY_FOUND" ]; then
  log_msg "Configuring primary display: $PRIMARY_FOUND @ ${PRIMARY_RATE}Hz"

  # Disable all other connected displays
  for output in $(xrandr | grep " connected " | awk '{print $1}'); do
    if [ "$output" != "$PRIMARY_FOUND" ]; then
      log_msg "Disabling display: $output"
      xrandr --output "$output" --off 2>/dev/null || true
    fi
  done

  # Configure primary display
  # Note: --pos 0x0 may fail if X server is already configured; we try without position to at least get display working
  if xrandr --output "$PRIMARY_FOUND" --mode 2560x1440 --rate "$PRIMARY_RATE" --primary 2>/dev/null; then
    log_msg "Primary display configured: 2560x1440 @ ${PRIMARY_RATE}Hz"
  else
    xrandr --output "$PRIMARY_FOUND" --mode 2560x1440 --primary 2>/dev/null
    log_msg "Primary display configured: 2560x1440"
  fi

  # Try to set position to 0x0 (may fail in some X configs)
  xrandr --output "$PRIMARY_FOUND" --pos 0x0 2>/dev/null || log_msg "Note: Could not set position (X server limitation)"
else
  log_msg "ERROR: No primary display found"
fi

log_msg 'Display configuration complete'
log_msg "SDDM greeter will appear only on $PRIMARY_CONNECTOR @ ${PRIMARY_RATE}Hz"
SCRIPTEOF
)

  if $DRY_RUN; then
    log "[dry-run] would create display-setup.sh script"
  else
    # Create scripts directory
    run sudo mkdir -p "$sddm_scripts_dir"

    # Backup existing script if it exists
    if [[ -f "$display_setup_script" ]]; then
      mkdir -p "$bkp_dir"
      local timestamp
      timestamp=$(date +%Y%m%d_%H%M%S)
      run sudo cp "$display_setup_script" "$bkp_dir/display-setup.sh.$timestamp"
      log "Backed up existing display-setup.sh script"
    fi

    # Write new script
    echo "$script_content" | run sudo tee "$display_setup_script" >/dev/null
    run sudo chmod +x "$display_setup_script"
    ok "Created display-setup.sh for single display greeter"
  fi

  # Notify about restart requirement
  log "SDDM X11 single display configuration complete"
  log "IMPORTANT: Restart SDDM or reboot for changes to take effect"
}

###############################################################################
# broadcom-wl-dkms - Blacklist conflicting wifi modules + switch to wpa_supplicant
###############################################################################

install_broadcom_blacklist() {
  # Check if broadcom-wl-dkms is installed
  if ! yay -Q broadcom-wl-dkms &>/dev/null; then
    log "broadcom-wl-dkms not installed — skipping blacklist"
    return 0
  fi

  local conf_file="/etc/modprobe.d/broadcom-wl-dkms.conf"
  local nm_conf_dir="/etc/NetworkManager/conf.d"
  local nm_wifi_conf="$nm_conf_dir/wifi_backend.conf"

  if $DRY_RUN; then
    log "[dry-run] would create broadcom-wl blacklist at $conf_file"
    log "[dry-run] would switch wifi backend to wpa_supplicant"
  else
    # Create blacklist for conflicting modules
    run sudo tee "$conf_file" >/dev/null << 'EOF'
# Blacklist conflicting Broadcom wifi modules
# This allows broadcom-wl-dkms to work properly
blacklist b43
blacklist b43legacy
blacklist bcm43xx
blacklist bcma
blacklist brcm80211
blacklist brcmfmac
blacklist brcmsmac
blacklist ssb
EOF
    ok "Created broadcom-wl blacklist"

    # Switch wifi backend to wpa_supplicant (broadcom-wl-dkms has issues with iwd)
    # See: https://gitlab.archlinux.org/archlinux/packaging/packages/broadcom-wl-dkms/-/issues/1
    run sudo mkdir -p "$nm_conf_dir"
    run sudo tee "$nm_wifi_conf" >/dev/null << 'EOF'
[device]
wifi.backend=wpa_supplicant
EOF
    ok "Switched wifi backend to wpa_supplicant (broadcom-wl-dkms compatibility)"
    log "Note: Restart NetworkManager or reboot for wifi to work"
  fi
}

###############################################################################
# Install custom fonts
# Copies font directories from arch-patches/fonts to /usr/local/share/fonts
###############################################################################

install_custom_fonts() {
  local src_fonts_dir="$DOTFILES_DIR/arch-patches/fonts"
  local dest_fonts_base="/usr/local/share/fonts"

  # Check if source fonts exist
  if [[ ! -d "$src_fonts_dir" ]]; then
    log "Custom fonts source not found at $src_fonts_dir — skipping"
    return 0
  fi

  # Find all format directories (ttf, otf, etc.) in src
  local -a format_dirs
  mapfile -t format_dirs < <(find "$src_fonts_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

  if (( ${#format_dirs[@]} == 0 )); then
    log "No font format directories found in $src_fonts_dir — skipping"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would install custom fonts"
    for format_dir in "${format_dirs[@]}"; do
      local src_format_dir="$src_fonts_dir/$format_dir"
      for font_dir in "$src_format_dir"/*/; do
        local font_name
        font_name=$(basename "$font_dir")
        log "  $format_dir/$font_name → $dest_fonts_base/$format_dir/"
      done
    done
    return 0
  fi

  step "Installing custom fonts"

  # Process each format directory (ttf, otf, etc.)
  for format_dir in "${format_dirs[@]}"; do
    local src_format_dir="$src_fonts_dir/$format_dir"
    local dest_format_dir="$dest_fonts_base/$format_dir"

    # Create format directory (e.g., /usr/local/share/fonts/ttf)
    run sudo mkdir -p "$dest_format_dir"

    # Find all font name directories in this format directory
    for font_dir in "$src_format_dir"/*/; do
      [[ -d "$font_dir" ]] || continue

      local font_name
      font_name=$(basename "$font_dir")
      log "  Installing font: $format_dir/$font_name"

      # Copy font directory to destination
      run sudo cp -r "$font_dir" "$dest_format_dir/"
      ok "  Installed $font_name"
    done
  done

  # Rebuild font cache
  if command -v fc-cache &>/dev/null; then
    run sudo fc-cache -f "$dest_fonts_base"
    ok "Font cache rebuilt"
  fi

  log "Custom fonts installed to $dest_fonts_base"
  log "Note: Log out and back in for fonts to appear in applications"
}

###############################################################################
# Install Noctalia SDDM theme files
# Copies prepared Main.qml, NComboBox.qml, and Settings.conf to the SDDM theme
###############################################################################

install_noctalia_sddm_theme() {
  local src_theme_dir="$SCRIPT_DIR/data/noctalia-sddm-theme"
  local dest_theme_dir="/usr/share/sddm/themes/sddm-noctalia-theme"
  local dest_widgets_dir="$dest_theme_dir/Widgets"
  local bkp_dir="$HOME/.local/share/neo-dots/sddm-bkp"

  # Check if source files exist
  if [[ ! -d "$src_theme_dir" ]]; then
    log "Noctalia SDDM theme source not found at $src_theme_dir — skipping"
    return 0
  fi

  # Check if target theme directory exists
  if [[ ! -d "$dest_theme_dir" ]]; then
    log "SDDM Noctalia theme not installed — skipping"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] would install Noctalia SDDM theme files"
    log "  Main.qml → $dest_theme_dir/"
    log "  NComboBox.qml → $dest_widgets_dir/"
    log "  Settings.conf → $dest_theme_dir/Commons/"
    return 0
  fi

  # Backup existing files
  mkdir -p "$bkp_dir"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)

  if [[ -f "$dest_theme_dir/Main.qml" ]]; then
    run sudo cp "$dest_theme_dir/Main.qml" "$bkp_dir/Main.qml.$timestamp"
    log "Backed up Main.qml to $bkp_dir"
  fi

  if [[ -f "$dest_widgets_dir/NComboBox.qml" ]]; then
    run sudo cp "$dest_widgets_dir/NComboBox.qml" "$bkp_dir/NComboBox.qml.$timestamp"
    log "Backed up NComboBox.qml to $bkp_dir"
  fi

  # Copy new files
  run sudo cp "$src_theme_dir/Main.qml" "$dest_theme_dir/Main.qml"
  ok "Installed Main.qml"

  run sudo cp "$src_theme_dir/NComboBox.qml" "$dest_widgets_dir/NComboBox.qml"
  ok "Installed NComboBox.qml"

  # Copy Settings.conf to Commons directory
  if [[ -f "$src_theme_dir/Settings.conf" ]]; then
    local dest_commons_dir="$dest_theme_dir/Commons"
    run sudo mkdir -p "$dest_commons_dir"
    run sudo cp "$src_theme_dir/Settings.conf" "$dest_commons_dir/Settings.conf"
    ok "Installed Settings.conf"
  fi

  log "Noctalia SDDM theme files installed"
  log "Note: Restart SDDM to see changes"
}
