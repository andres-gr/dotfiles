###############################################################################
# Splash Screens - extract tarball with splash animations
###############################################################################

# Get script directory if not already set (for standalone sourcing)
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)}"

install_splash_screens() {
  local splash_tar="$DOTFILES_DIR/scripts/patches/data/splash-screens.tar"
  local dest_dir="$HOME/.local/assets"
  local splashes_dir="$dest_dir/splashes"

  # Already installed?
  [[ -d "$splashes_dir" ]] && {
    log "Splash screens already installed — skipping"
    return 0
  }

  # No tarball?
  [[ ! -f "$splash_tar" ]] && {
    log "Splash screens tarball not found — skipping"
    return 0
  }

  $DRY_RUN && { log "[dry-run] would extract splash screens"; return 0; }

  step "Installing Splash Screens"
  run mkdir -p "$dest_dir"
  run tar -xvf "$splash_tar" -C "$dest_dir"
  ok "Splash screens installed to ~/.local/assets"
}