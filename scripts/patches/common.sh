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

  # Ensure wallpaper is writable for user updates (always run)
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
