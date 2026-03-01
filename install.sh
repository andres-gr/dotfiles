#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#######################################
# Globals
#######################################

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=""
DRY_RUN=false
UNINSTALL=false
PROFILE=""
BREW_SELECTION=""
ARCH_SELECTION=""
STOW_SELECTION=""
INSTALL_GITCONFIG=false
RUN_POST_INSTALL=false

#######################################
# Logging
#######################################

log()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1"; }

run() {
  if $DRY_RUN; then
    echo "[DRY RUN] $*"
  else
    eval "$@"
  fi
}

#######################################
# OS Detection
#######################################

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)
      if grep -qi arch /etc/os-release 2>/dev/null; then
        OS="arch"
      else
        err "Unsupported Linux distro"
        exit 1
      fi
      ;;
    *) err "Unsupported OS"; exit 1 ;;
  esac

  log "Detected OS: $OS"
}

#######################################
# Argument Parsing
#######################################

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --uninstall) UNINSTALL=true ;;
      --profile) PROFILE="$2"; shift ;;
      --brew) BREW_SELECTION="$2"; shift ;;
      --arch-pkgs) ARCH_SELECTION="$2"; shift ;;
      --stow) STOW_SELECTION="$2"; shift ;;
      --gitconfig) INSTALL_GITCONFIG=true ;;
      --post-install) RUN_POST_INSTALL=true ;;
      --help)
        echo "Usage: ./install.sh [options]"
        exit 0
        ;;
      *) err "Unknown option: $1"; exit 1 ;;
    esac
    shift
  done
}

#######################################
# Stow
#######################################

stow_package() {
  local pkg="$1"
  log "Stowing $pkg"
  run "stow -d \"$DOTFILES_DIR\" -t \"$HOME\" \"$pkg\""
}

unstow_package() {
  local pkg="$1"
  log "Unstowing $pkg"
  run "stow -D -d \"$DOTFILES_DIR\" -t \"$HOME\" \"$pkg\""
}

#######################################
# Brew
#######################################

brew_install_file() {
  local file="$1"
  log "Installing Brewfile: $file"
  run "brew bundle --file=\"$DOTFILES_DIR/homebrew/$file\""
}

#######################################
# Arch
#######################################

arch_install_list() {
  local file="$1"
  log "Installing Arch packages from: $file"
  run "yay -S --needed --noconfirm $(cat \"$DOTFILES_DIR/arch-pkgs/$file\")"
}

#######################################
# Gitconfig Handling
#######################################

install_gitconfig() {
  local src="$DOTFILES_DIR/.gitconfig"
  local dest="$HOME/.gitconfig"

  if [[ -f "$dest" ]]; then
    log "Backing up existing .gitconfig"
    run "cp \"$dest\" \"$dest.bak.$(date +%s)\""
  fi

  log "Copying dotfiles .gitconfig"
  run "cp \"$src\" \"$dest\""

  if ! $DRY_RUN; then
    read -rp "Enter git user.name: " git_name
    read -rp "Enter git user.email: " git_email

    git config --file "$dest" user.name "$git_name"
    git config --file "$dest" user.email "$git_email"
  fi
}

#######################################
# Profiles
#######################################

run_profile() {

  case "$PROFILE" in
    base)
      local base_packages=(
        bat
        eza
        ghostty
        lazygit
        local
        nvim
        starship
        tmux
        zsh
      )

      for pkg in "${base_packages[@]}"; do
        stow_package "$pkg"
      done
      ;;
    macos)
      [[ "$OS" == "macos" ]] || { err "Not macOS"; exit 1; }
      stow_package macos
      ;;
    arch)
      [[ "$OS" == "arch" ]] || { err "Not Arch"; exit 1; }
      stow_package arch-linux
      ;;
    "")
      ;;
    *)
      err "Unknown profile: $PROFILE"
      exit 1
      ;;
  esac
}

#######################################
# Brew Selection
#######################################

handle_brew() {
  [[ "$OS" == "macos" ]] || return

  case "$BREW_SELECTION" in
    taps) brew_install_file "Brewfile.taps" ;;
    core) brew_install_file "Brewfile.core" ;;
    casks) brew_install_file "Brewfile.casks" ;;
    vscode) brew_install_file "Brewfile.vscode" ;;
    work) brew_install_file "Brewfile.work" ;;
    windowmanager) brew_install_file "Brewfile.windowmanager" ;;
    all)
      brew_install_file "Brewfile.taps"
      brew_install_file "Brewfile.core"
      brew_install_file "Brewfile.casks"
      brew_install_file "Brewfile.vscode"
      ;;
    "")
      ;;
    *)
      err "Invalid brew selection"
      exit 1
      ;;
  esac
}

#######################################
# Arch Selection
#######################################

handle_arch() {
  [[ "$OS" == "arch" ]] || return

  case "$ARCH_SELECTION" in
    core) arch_install_list "core.txt" ;;
    aur) arch_install_list "aur.txt" ;;
    all)
      arch_install_list "core.txt"
      arch_install_list "aur.txt"
      ;;
    "")
      ;;
    *)
      err "Invalid arch selection"
      exit 1
      ;;
  esac
}

#######################################
# Post Install Tasks
#######################################

post_install() {
  log "Running post-install tasks..."

  # Install TPM (tmux plugin manager)
  if command -v tmux &>/dev/null; then
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
      log "Installing tmux TPM..."
      run "git clone https://github.com/tmux-plugins/tpm \"$HOME/.tmux/plugins/tpm\""
    else
      log "TPM already installed."
    fi
  fi

  # Future hooks:
  # - nvim plugin sync
  # - zsh compinit cache warmup
  # - starship preset setup
}

#######################################
# Uninstall
#######################################

run_uninstall() {
  log "Uninstalling stow packages..."
  for pkg in bat eza ghostty lazygit local nvim starship tmux zsh macos arch-linux; do
    unstow_package "$pkg" || true
  done
}

#######################################
# Main
#######################################

main() {
  detect_os
  parse_args "$@"

  if $UNINSTALL; then
    run_uninstall
    exit 0
  fi

  run_profile
  handle_brew
  handle_arch

  if $INSTALL_GITCONFIG; then
    install_gitconfig
  fi

  if $RUN_POST_INSTALL; then
    post_install
  fi

  log "Done."
}

main "$@"
