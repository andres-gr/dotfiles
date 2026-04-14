###############################################################################
# Steam Splash -extract tarball only
###############################################################################

install_steam_splash() {
  local splash_tar="$DOTFILES_DIR/scripts/patches/data/steam-girl-splash.tar"
  local dest_dir="$HOME/.local"
  local bin_script="$dest_dir/bin/steam-girl-splash"

  # Already installed?
  [[ -f "$bin_script" ]] && {
    log "Steam splash already installed — skipping"
    return 0
  }

  # No tarball?
  [[ ! -f "$splash_tar" ]] && {
    log "Steam splash tarball not found — skipping"
    return 0
  }

  $DRY_RUN && { log "[dry-run] would extract steam splash"; return 0; }

  step "Installing Steam Splash"
  run tar -xvf "$splash_tar" -C "$dest_dir"
  run chmod +x "$bin_script"
  ok "Steam splash installed"
}