#!/usr/bin/env bash
# bootstrap.sh — Dependency installer for dotfiles
# Supports: macOS, Arch Linux, CachyOS
#
# Usage:
#   ./bootstrap.sh    # Detect OS, check deps, install missing
#   source bootstrap.sh  # Load functions only (for manual use)
#
# Note: This script sources install.sh to reuse detection logic.

###############################################################################
# Globals - will be set by detect_os() from install.sh
###############################################################################

# Dependencies required for all OS
REQUIRED_DEPS=(gum stow)

# Get DOTFILES_DIR (directory containing this script)
_get_dotfiles_dir() {
  # When sourced, BASH_SOURCE[1] is the calling script
  local source="${BASH_SOURCE[0]:-${BASH_SOURCE[1]}}"
  if [[ -z "$source" ]]; then
    # Fallback: use current working directory
    echo "$(pwd)"
    return
  fi
  while [[ -h "$source" ]]; do
    local dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ $source != /* ]] && source="$dir/$source"
  done
  echo "$(cd -P "$(dirname "$source")" && pwd)"
}

DOTFILES_DIR="$(_get_dotfiles_dir)"

###############################################################################
# Note: Logging functions (log, ok, warn, err) are provided by install.sh
# when it is sourced below. No need to define them here.

###############################################################################
# Source install.sh to get detection logic
###############################################################################

# Source install.sh for OS detection (sets OS, DISTRO_ID)
# We only need the detection variables and functions, not to run main()
# shellcheck source=install.sh
source "$DOTFILES_DIR/install.sh" --source-only

###############################################################################
# Dependency Checking
###############################################################################

# check_dependencies - Returns list of missing tools
# Output: prints missing tool names, one per line
check_dependencies() {
  local missing=()

  for tool in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done

  # For macOS, also check if brew is installed
  if [[ "$OS" == "macos" ]]; then
    if ! command -v brew &>/dev/null; then
      missing+=("brew")
    fi
  fi

  # For Arch, also check if yay is installed (required for AUR)
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    if ! command -v yay &>/dev/null; then
      missing+=("yay")
    fi
  fi

  # Print missing tools
  if (( ${#missing[@]} > 0 )); then
    printf '%s\n' "${missing[@]}"
  fi
}

###############################################################################
# Installation Functions
###############################################################################

# install_brew - Install Homebrew on macOS
install_brew() {
  log "Installing Homebrew..."
  if command -v brew &>/dev/null; then
    ok "Homebrew already installed"
    return 0
  fi

  # Run official Homebrew install script
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for current session (if not already there)
  if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
  if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi

  ok "Homebrew installed"
}

# install_macos_deps - Install dependencies on macOS
install_macos_deps() {
  local missing
  missing="$(check_dependencies)"

  # Check if brew is missing first
  if echo "$missing" | grep -qx "brew"; then
    install_brew
  fi

  # Ensure brew is in PATH
  if [[ ":$PATH:" != *":/usr/local/bin:"* ]] && [[ -x /usr/local/bin/brew ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
  if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi

  # Install gum and stow via brew
  local to_install=()
  if echo "$missing" | grep -qx "gum"; then
    to_install+=("gum")
  fi
  if echo "$missing" | grep -qx "stow"; then
    to_install+=("stow")
  fi

  if (( ${#to_install[@]} > 0 )); then
    log "Installing: ${to_install[*]}"
    brew install "${to_install[@]}"
    ok "Installed: ${to_install[*]}"
  else
    ok "All dependencies already installed"
  fi
}

# install_arch_deps - Install dependencies on Arch Linux
install_arch_deps() {
  local missing
  missing="$(check_dependencies)"

  # Check if yay is missing
  if echo "$missing" | grep -qx "yay"; then
    err "yay is required but not installed. Please install yay first."
    return 1
  fi

  # Install gum and stow via yay
  local to_install=()
  if echo "$missing" | grep -qx "gum"; then
    to_install+=("gum")
  fi
  if echo "$missing" | grep -qx "stow"; then
    to_install+=("stow")
  fi

  if (( ${#to_install[@]} > 0 )); then
    log "Installing: ${to_install[*]}"
    yay -S --needed --noconfirm "${to_install[@]}"
    ok "Installed: ${to_install[*]}"
  else
    ok "All dependencies already installed"
  fi
}

# install_deps - Main installation function
install_deps() {
  # Detect OS first
  if ! detect_os; then
    err "Failed to detect OS"
    return 1
  fi

  # Check for missing dependencies
  local missing
  missing="$(check_dependencies)"

  if [[ -z "$missing" ]]; then
    ok "All dependencies already installed"
    return 0
  fi

  log "Missing dependencies: $missing"

  # Install based on OS
  case "$OS" in
    macos)
      install_macos_deps
      ;;
    arch|cachyos)
      install_arch_deps
      ;;
    *)
      err "Unsupported OS: $OS"
      return 1
      ;;
  esac
}

###############################################################################
# Main
###############################################################################

main() {
  # Check if script is being sourced or executed
  if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed
    if ! install_deps; then
      err "Dependency installation failed"
      exit 1
    fi
    ok "Bootstrap complete"
    exit 0
  else
    # Script is being sourced - just load functions
    log "Bootstrap functions loaded (source this file for manual use)"
  fi
}

main "$@"
