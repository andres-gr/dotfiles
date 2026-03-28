#!/usr/bin/env bash
# common.sh - Generic patches for Arch Linux
# Called from post_install_task in install.sh
# These patches run regardless of which WM/DE is used

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
# Ghostty arch-config
# Creates platform-specific overrides for Ghostty terminal
###############################################################################

install_ghostty_arch_config() {
  local ghostty_config_dir="$HOME/.config/ghostty"
  local arch_config="$ghostty_config_dir/arch-config"

  if [[ ! -d "$ghostty_config_dir" ]]; then
    log "Ghostty config directory not found — skipping arch-config"
    return
  fi

  # Detect if we should use Arch or macOS config
  local is_arch=false
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    is_arch=true
  fi

  if $is_arch; then
    log "Creating Ghostty Arch overrides: $arch_config"
    run mkdir -p "$ghostty_config_dir"
    if $DRY_RUN; then
      log "[dry-run] would write to $arch_config:"
      log "  background-opacity = 1"
      log "  background-blur = 0"
      log "  font-size = 11"
      log "  keybind = ctrl+enter=unbind"
    else
      printf 'background-opacity = 1\nbackground-blur = 0\nfont-size = 11\nkeybind = ctrl+enter=unbind' > "$arch_config"
      ok "  wrote $arch_config"
    fi
  else
    # For macOS or other systems, create empty file if it doesn't exist
    run mkdir -p "$ghostty_config_dir"
    if [[ ! -e "$arch_config" ]]; then
      if $DRY_RUN; then
        log "[dry-run] would create empty file at $arch_config:"
        log "  touch $arch_config"
      else
        log "Creating empty Ghostty arch-config for macOS"
        run touch "$arch_config"
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
  install_ghostty_arch_config
  apply_arch_patch_dconf
  install_arch_patch_services
}
