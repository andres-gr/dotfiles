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
INTERACTIVE=false

TASKS=()

STOW_SELECTED=()
BREW_SELECTED=()
ARCH_SELECTED=()

#######################################
# Central Package Definitions
#######################################

BASE_STOW_PKGS=(bat eza ghostty lazygit local nvim starship tmux zsh)
MACOS_STOW_PKGS=(macos)
ARCH_STOW_PKGS=(arch-linux)

BREW_FILES=(Brewfile.taps Brewfile.core Brewfile.casks Brewfile.vscode Brewfile.work Brewfile.windowmanager)
ARCH_PKG_FILES=(core.txt aur.txt)

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
      grep -qi arch /etc/os-release && OS="arch" || {
        err "Unsupported Linux distro"; exit 1
      }
      ;;
    *) err "Unsupported OS"; exit 1 ;;
  esac
  log "Detected OS: $OS"
}

#######################################
# Stow Logic
#######################################

stow_packages() {
  for pkg in "$@"; do
    log "Stowing $pkg"
    run "stow -d \"$DOTFILES_DIR\" -t \"$HOME\" \"$pkg\""
  done
}

unstow_all() {
  local all_pkgs=(
    "${BASE_STOW_PKGS[@]}"
    "${MACOS_STOW_PKGS[@]}"
    "${ARCH_STOW_PKGS[@]}"
  )

  for pkg in "${all_pkgs[@]}"; do
    run "stow -D -d \"$DOTFILES_DIR\" -t \"$HOME\" \"$pkg\"" || true
  done
}

#######################################
# Brew
#######################################

brew_install() {
  local file="$1"
  log "Installing $file"
  run "brew bundle --file=\"$DOTFILES_DIR/homebrew/$file\""
}

#######################################
# Arch
#######################################

arch_install() {
  local file="$1"
  log "Installing Arch packages from $file"
  run "yay -S --needed --noconfirm $(cat \"$DOTFILES_DIR/arch-pkgs/$file\")"
}

#######################################
# Gitconfig
#######################################

install_gitconfig_task() {
  local src="$DOTFILES_DIR/.gitconfig"
  local dest="$HOME/.gitconfig"

  if [[ -f "$dest" ]]; then
    log "Backing up existing .gitconfig"
    run "cp \"$dest\" \"$dest.bak.$(date +%s)\""
  fi

  run "cp \"$src\" \"$dest\""

  if $DRY_RUN; then
    log "[DRY RUN] Would prompt for git user.name and user.email"
  else
    read -rp "Enter git user.name: " git_name
    read -rp "Enter git user.email: " git_email
    git config --file "$dest" user.name "$git_name"
    git config --file "$dest" user.email "$git_email"
  fi
}

#######################################
# Post Install
#######################################

post_install_task() {
  log "Running post-install tasks"

  if command -v tmux &>/dev/null; then
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
      log "Installing TPM"
      run "git clone https://github.com/tmux-plugins/tpm \"$HOME/.tmux/plugins/tpm\""
    else
      log "TPM already installed, skipping"
    fi
  fi
}

#######################################
# Task Registration
#######################################

register_task() {
  TASKS+=("$1")
}

execute_tasks() {
  for task in "${TASKS[@]}"; do
    "$task"
  done
}

#######################################
# Interactive Mode
#######################################

interactive_select() {
  if command -v fzf &>/dev/null; then
    printf "%s\n" "$@" | fzf --multi
    return $?
  else
    select opt in "$@" "Skip"; do
      if [[ "$opt" == "Skip" ]]; then
        return 1
      fi
      [[ -n "$opt" ]] && echo "$opt"
      break
    done
  fi
}

interactive_mode() {
  log "Entering interactive mode"

  if $DRY_RUN; then
    warn "Dry-run: skipping interactive prompts, registering all tasks as simulation"
    STOW_SELECTED=("${BASE_STOW_PKGS[@]}")
    register_task "stow_selected"
    if [[ "$OS" == "macos" ]]; then
      STOW_SELECTED+=("${MACOS_STOW_PKGS[@]}")
      BREW_SELECTED=("${BREW_FILES[@]}")
      register_task "brew_selected"
    elif [[ "$OS" == "arch" ]]; then
      STOW_SELECTED+=("${ARCH_STOW_PKGS[@]}")
      ARCH_SELECTED=("${ARCH_PKG_FILES[@]}")
      register_task "arch_selected"
    fi
    register_task "install_gitconfig_task"
    register_task "post_install_task"
    return
  fi

  # --------------------------------------------------
  # Stow: base + OS-specific packages
  # --------------------------------------------------
  local all_stow_pkgs=("${BASE_STOW_PKGS[@]}")
  if [[ "$OS" == "macos" ]]; then
    all_stow_pkgs+=("${MACOS_STOW_PKGS[@]}")
  elif [[ "$OS" == "arch" ]]; then
    all_stow_pkgs+=("${ARCH_STOW_PKGS[@]}")
  fi

  local selected
  if selected=$(interactive_select "${all_stow_pkgs[@]}"); then
    if [[ -n "$selected" ]]; then
      STOW_SELECTED=($selected)
      register_task "stow_selected"
    else
      log "Skipping stow step"
    fi
  else
    log "Skipped stow step"
  fi

  # --------------------------------------------------
  # OS-specific package install
  # --------------------------------------------------
  if [[ "$OS" == "macos" ]]; then
    log "Select Brewfiles to install (space to select, enter to confirm):"
    local brew_selected
    if brew_selected=$(interactive_select "${BREW_FILES[@]}"); then
      if [[ -n "$brew_selected" ]]; then
        BREW_SELECTED=($brew_selected)
        register_task "brew_selected"
      else
        log "Skipping brew step"
      fi
    else
      log "Skipped brew step"
    fi
  fi

  if [[ "$OS" == "arch" ]]; then
    log "Select Arch package files to install:"
    local arch_selected
    if arch_selected=$(interactive_select "${ARCH_PKG_FILES[@]}"); then
      if [[ -n "$arch_selected" ]]; then
        ARCH_SELECTED=($arch_selected)
        register_task "arch_selected"
      else
        log "Skipping arch packages step"
      fi
    else
      log "Skipped arch packages step"
    fi
  fi

  # --------------------------------------------------
  # Optional tasks
  # --------------------------------------------------
  local ans
  read -rp "Install gitconfig? (y/N): " ans
  [[ "$ans" =~ ^[Yy]$ ]] && register_task "install_gitconfig_task"

  read -rp "Run post-install? (y/N): " ans
  [[ "$ans" =~ ^[Yy]$ ]] && register_task "post_install_task"
}

stow_selected() {
  stow_packages "${STOW_SELECTED[@]}"
}

brew_selected() {
  for f in "${BREW_SELECTED[@]}"; do
    brew_install "$f"
  done
}

arch_selected() {
  for f in "${ARCH_SELECTED[@]}"; do
    arch_install "$f"
  done
}

#######################################
# Argument Parsing
#######################################

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)      DRY_RUN=true ;;
      --uninstall)    UNINSTALL=true ;;
      --interactive)  INTERACTIVE=true ;;
      --gitconfig)    register_task "install_gitconfig_task" ;;
      --post-install) register_task "post_install_task" ;;
      --help)
        echo "Usage: ./install.sh [--interactive|--dry-run|--uninstall|--gitconfig|--post-install]"
        exit 0
        ;;
      *) err "Unknown option: $1"; exit 1 ;;
    esac
    shift
  done
}

#######################################
# Main
#######################################

default_base() {
  stow_packages "${BASE_STOW_PKGS[@]}"
}

main() {
  local original_args=("$@")

  detect_os
  parse_args "$@"

  if $UNINSTALL; then
    unstow_all
    exit 0
  fi

  # No args (or only --dry-run) → default to interactive
  if [[ ${#original_args[@]} -eq 0 ]] || [[ ${#original_args[@]} -eq 1 && "$DRY_RUN" == true ]]; then
    INTERACTIVE=true
  fi

  if $INTERACTIVE; then
    interactive_mode
  else
    register_task "default_base"
  fi

  execute_tasks
  log "Done"
}

main "$@"
