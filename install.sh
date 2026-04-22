#!/usr/bin/env bash
# install.sh — dotfiles installer
# Supports: macOS, Arch Linux (bare or on top of an existing HyDE installation)
#
# HyDE-aware behaviour:
#   When HyDE is detected the installer will:
#     • Back up any HyDE-owned file that stow would overwrite
#     • Preserve HyDE's conf.d/hyde/ dir and 00-hyde.zsh entry-point
#     • Preserve HyDE's CLI completion files (hyde-shell, hydectl)
#     • Prompt for how Starship should be configured (3 modes, see below)
#     • Inject the correct override into $ZDOTDIR/user.zsh so only ONE
#       starship init ever fires per session
#     • Optionally reload HyDE / Hyprland after install
#
# Starship modes (only prompted when HyDE is present):
#   dotfiles — stow our starship/ pkg; disable HyDE prompt via user.zsh
#   hyde     — skip stowing starship/; HyDE owns starship and its config
#   env      — skip stowing starship/; set custom STARSHIP_CONFIG path;
#              disable HyDE prompt so our 60-tools.zsh fires starship init

set -euo pipefail
IFS=$'\n\t'

###############################################################################
# Globals
###############################################################################
# Source-only mode (used by bootstrap.sh)
###############################################################################

# Check if being sourced vs executed
# When sourced, BASH_SOURCE[0] will be the sourcing script, not this one
# We detect sourcing by checking if the script name doesn't match
###############################################################################
# Globals
###############################################################################

# Get directory of this script - fallback to pwd if unavailable
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  DOTFILES_DIR="$(pwd)"
fi
OS=""                  # "macos" | "arch" | "cachyos"
DISTRO_ID=""           # "arch" | "cachyos" (for Linux)
COMPOSITOR=""           # "hyprland" | "niri" | "none"
DRY_RUN=false
UNINSTALL=false
INTERACTIVE=false

TASKS=()
STOW_SELECTED=()
BREW_SELECTED=()
ARCH_SELECTED=()
PATCHES_SELECTED=()

# HyDE — populated by detect_de()
HYDE_DETECTED=false
HYDE_SHELL_BIN=""   # full path to hyde-shell binary
HYDE_CTL_BIN=""     # full path to hydectl binary

# Niri — populated by detect_de()
NIRI_DETECTED=false

# DMS (Dank Material Shell) — populated by detect_de()
DMS_DETECTED=false

# Noctalia — populated by detect_de()
NOCTALIA_DETECTED=false

# Greetd — populated by detect_de()
GREETD_DETECTED=false

# Hyprland — populated by detect_de()
HYPRLAND_DETECTED=false

# Starship — resolved by prompt_starship_mode()
STARSHIP_MODE="dotfiles"   # dotfiles | hyde | env

# Backup timestamp — same across the whole run so all backups share a folder
BKP_TS="$(date +%Y%m%d_%H%M%S)"

###############################################################################
# Package lists
###############################################################################

BASE_STOW_PKGS=(bat claude eza fastfetch ghostty lazygit local nvim starship tmux zsh)
MACOS_STOW_PKGS=(macos)

# Arch Linux stow packages (selected based on COMPOSITOR)
ARCH_COMMON_PKGS=(arch-common)
ARCH_HYDE_PKGS=(arch-hyde)
ARCH_NIRI_PKGS=(arch-niri)

# Arch Linux stow packages — hyprland base (standalone, no HyDE)
ARCH_HYPRLAND_PKGS=(arch-hyprland)

# Full ordered list of arch pkg files (shown in interactive chooser)
ARCH_PKG_FILES_ALL=(
  core.txt
  aur.txt
  work.txt
  hyprland-core.txt
  hyde-core.txt
  hyde-aur.txt
  niri-core.txt
  niri-aur.txt
  dank-core.txt
  dank-aur.txt
  noctalia-aur.txt
)

# Shell-specific stow packages (can overlay DE-specific configs)
SHELL_STOW_PKGS=()
NOCTALIA_STOW_PKGS=(arch-noctalia)
DANK_STOW_PKGS=(arch-dank)

# Optional stow packages (available on any platform, can override earlier files)
OPTIONAL_STOW_PKGS=(opencode yazi)

# Maps each DE-dependent stow package to its required detection.
# Format: [pkg]="VAR_NAME:expected_value:display_label"
# VAR_NAME is a global boolean flag or "COMPOSITOR" (special case).
declare -A STOW_PKG_REQUIRES=(
  [arch-hyprland]="COMPOSITOR:hyprland:Hyprland compositor"
  [arch-niri]="COMPOSITOR:niri:Niri compositor"
  [arch-hyde]="HYDE_DETECTED:true:HyDE"
  [arch-noctalia]="NOCTALIA_DETECTED:true:Noctalia"
  [arch-dank]="DMS_DETECTED:true:DMS"
)

# Maps each DE-dependent pkg file to its required detection.
# Same format as STOW_PKG_REQUIRES.
declare -A PKG_FILE_REQUIRES=(
  [hyprland-core.txt]="COMPOSITOR:hyprland:Hyprland compositor"
  [hyde-core.txt]="HYDE_DETECTED:true:HyDE"
  [hyde-aur.txt]="HYDE_DETECTED:true:HyDE"
  [niri-core.txt]="COMPOSITOR:niri:Niri compositor"
  [niri-aur.txt]="COMPOSITOR:niri:Niri compositor"
  [dank-core.txt]="DMS_DETECTED:true:DMS"
  [dank-aur.txt]="DMS_DETECTED:true:DMS"
  [noctalia-aur.txt]="NOCTALIA_DETECTED:true:Noctalia"
)

# Patch file definitions: patch_name -> (script_file, os_filter)
# os_filter: "arch" (arch/cachyos), "macos", "all"
# Note: patch scripts self-guard with internal detection checks
declare -A PATCH_FILES=(
  [common]="scripts/patches/common.sh:all"
  [hyprland]="scripts/patches/hyprland.sh:all"
  [niri]="scripts/patches/niri.sh:all"
  [noctalia]="scripts/patches/noctalia.sh:all"
  [dank]="scripts/patches/dank.sh:all"
  [hyde]="scripts/patches/hyde.sh:all"
)

# Individual patch functions per patch file
# Format: patch_name="func1 func2 func3 ..."
declare -A PATCH_FUNCTIONS=(
  [common]="apply_arch_patch_dconf bootstrap_spicetify configure_amdgpu_early_kms configure_bluetooth configure_font_rendering configure_keyboard_layout install_arch_patch_services install_broadcom_blacklist install_custom_fonts install_ghostty_misc_config install_noctalia_sddm_theme install_pam_configs install_plymouth_boot_splash install_sddm_wayland_config install_sddm_x11_config install_spicetify_comfy_theme install_splash_screens install_systemd_scripts install_tpm install_yazi_plugins rebuild_kde_menucache save_raw_arch_packages"
  [hyprland]="configure_splash_hyprland configure_workspaces_persistent install_hymission install_hyprland_config reload_hyprland"
  [niri]="configure_splash_niri install_niri_config"
  [noctalia]="install_spotify_toast_plugin patch_zen_userchrome"
  [dank]="reload_dms"
  [hyde]="backup_hyde_zsh ensure_hyde_completions hyde_post_install hyde_seed_config"
)

# Descriptions for each patch function
# Format: func_name="description"
declare -A PATCH_FUNCTION_DESCRIPTIONS=(
  # common
  [apply_arch_patch_dconf]="Load dconf profiles for Arch patches"
  [bootstrap_spicetify]="Bootstrap spicetify for Spotify"
  [configure_amdgpu_early_kms]="Enable AMD GPU early KMS"
  [configure_bluetooth]="Disable Bluetooth AutoEnable to prevent auto-connect"
  [configure_font_rendering]="Configure font rendering (sub-pixel, hinting, LCD filter)"
  [configure_keyboard_layout]="Configure X11 keyboard layout (us pc105 altgr-intl)"
  [install_arch_patch_services]="Install systemd services for Arch patches"
  [install_broadcom_blacklist]="Blacklist conflicting wifi modules for broadcom-wl"
  [install_custom_fonts]="Install custom fonts to system"
  [install_ghostty_misc_config]="Configure Ghostty platform-specific settings"
  [install_noctalia_sddm_theme]="Install Noctalia SDDM theme with user dropdown"
  [install_pam_configs]="Install PAM configs for greetd"
  [install_plymouth_boot_splash]="Configure Plymouth boot splash with theme and kernel cmdline"
  [install_sddm_wayland_config]="Configure SDDM for Wayland single display"
  [install_sddm_x11_config]="Configure SDDM for X11 single display"
  [install_spicetify_comfy_theme]="Install/apply Comfy theme for Spicetify"
  [install_splash_screens]="Install splash screen animations to ~/.local"
  [install_systemd_scripts]="Install systemd scripts (e.g., system-sleep)"
  [install_tpm]="Install TPM (Tmux Plugin Manager)"
  [install_yazi_plugins]="Install/update yazi plugins"
  [rebuild_kde_menucache]="Rebuild KDE menu cache for Arch themes"
  [save_raw_arch_packages]="Save list of raw Arch packages"
  # hyprland
  [configure_splash_hyprland]="Configure Splash in Hyprland"
  [configure_workspaces_persistent]="Add persistent:true to workspaces"
  [install_hymission]="Install hymission Hyprland plugin"
  [install_hyprland_config]="Install main Hyprland hyprland.conf"
  [reload_hyprland]="Reload Hyprland configuration"
  # niri
  [configure_splash_niri]="Configure Splash in Niri"
  [install_niri_config]="Install main niri config.kdl"
  # dank
  [reload_dms]="Reload Dank Material Shell"
  # noctalia
  [install_spotify_toast_plugin]="Install Spotify Toast plugin"
  [patch_zen_userchrome]="Patch Zen Browser userChrome.css"
)

# For backward compatibility - will be dynamically selected in selection logic
ARCH_STOW_PKGS=()

# Detection flags
HYDE_DETECTED=false
HYDE_SHELL_BIN=""   # full path to hyde-shell binary
HYDE_CTL_BIN=""     # full path to hydectl binary

NIRI_DETECTED=false

# DMS (Dank Material Shell) — populated by detect_de()
DMS_DETECTED=false

# Noctalia — populated by detect_de()
NOCTALIA_DETECTED=false

# Greetd — populated by detect_de()
GREETD_DETECTED=false

# Hyprland — populated by detect_de()
HYPRLAND_DETECTED=false

BREW_FILES=(
  Brewfile.taps
  Brewfile.core
  Brewfile.casks
  Brewfile.vscode
  Brewfile.work
  Brewfile.windowmanager
)

ARCH_PKG_FILES=(core.txt aur.txt work.txt)

# Packages that must be removed before installing ours (conflicts)
# Format: "our-pkg:conflicting-installed-pkg"
ARCH_CONFLICTS=(
  "visual-studio-code-bin:code"
)

# HyDE-owned paths (relative to $HOME) that stow must not silently clobber.
# We back these up before stow touches anything, then verify they survive.
HYDE_OWNED_ZSH=(
  ".config/zsh/conf.d/hyde"              # env.zsh / prompt.zsh / terminal.zsh
  ".config/zsh/conf.d/00-hyde.zsh"       # HyDE's conf.d entry-point
  ".config/zsh/completions/hyde-shell.zsh"
  ".config/zsh/completions/hydectl.zsh"
  ".config/zsh/.zshenv"                  # HyDE's $ZDOTDIR/.zshenv (sources conf.d)
)

# HyDE config.toml — seeded once on first install, never overwritten
HYDE_CONFIG_TOML_SRC="$DOTFILES_DIR/arch-linux/.config/hyde/config.toml"
HYDE_CONFIG_TOML_DEST="$HOME/.config/hyde/config.toml"

###############################################################################
# Logging
###############################################################################

log()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*" >&2; }
ok()   { printf "\033[1;32m[ ok ]\033[0m  %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m  %s\n" "$*"; }
err()  { printf "\033[1;31m[err ]\033[0m  %s\n" "$*" >&2; }
step() { printf "\n\033[1;36m──── %s\033[0m\n" "$*"; }

###############################################################################
# run — execute a command, or print it in dry-run mode
# Uses an array so there is no eval and no word-splitting surprises.
###############################################################################

run() {
  if $DRY_RUN; then
    printf "[dry-run] %s\n" "$*"
  else
    "$@"
  fi
}

###############################################################################
# OS detection
###############################################################################

# detect_os - Detect operating system
# Sets: OS ("macos" | "arch" | "cachyos"), DISTRO_ID
detect_os() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      DISTRO_ID="macos"
      ;;
    Linux)
      # Detect specific distro from /etc/os-release
      if [[ -f /etc/os-release ]]; then
        # Source os-release to get ID and ID_LIKE
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_ID="$ID"

        # Check if it's a derivative (CachyOS, EndeavourOS, etc.)
        case "$ID" in
          cachyos)
            OS="cachyos"
            ;;
          arch|endeavouros)
            OS="arch"
            ;;
          *)
            # Check ID_LIKE for Arch-based distros
            if echo "$ID_LIKE" | grep -qi "arch"; then
              OS="arch"
              DISTRO_ID="$ID"  # Keep original ID for package selection
            else
              err "Unsupported Linux distro: $ID (only Arch-based distros are supported)"
              return 1
            fi
            ;;
        esac
      else
        err "Cannot detect distro: /etc/os-release not found"
        return 1
      fi
      ;;
    *)
      err "Unsupported OS: $(uname -s)"
      return 1
      ;;
  esac
  log "Detected OS: $OS (distro: ${DISTRO_ID:-unknown})"
  return 0
}

###############################################################################
# Desktop Environment / Window Manager detection
###############################################################################

# detect_de - Detect desktop environment and window manager
# Sets: COMPOSITOR ("hyprland" | "niri" | "none"), HYDE_DETECTED, NIRI_DETECTED, etc.
detect_de() {
  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"

  # Check for HyDE (Hyprland Development Environment)
  local hyde_zsh_dir="$zdotdir/conf.d/hyde"
  local hyde_config_dir="$HOME/.config/hyde"

  # Locate hyde-shell binary
  local -a hyde_shell_candidates
  mapfile -t hyde_shell_candidates < <(
    command -v hyde-shell 2>/dev/null || true
    printf '%s\n' \
      "$HOME/.local/bin/hyde-shell" \
      "/usr/local/bin/hyde-shell"
  )

  for c in "${hyde_shell_candidates[@]}"; do
    [[ -x "$c" ]] && { HYDE_SHELL_BIN="$c"; break; }
  done

  # Locate hydectl binary
  local -a hyde_ctl_candidates
  mapfile -t hyde_ctl_candidates < <(
    command -v hydectl 2>/dev/null || true
    printf '%s\n' \
      "$HOME/.local/bin/hydectl" \
      "/usr/local/bin/hydectl"
  )

  for c in "${hyde_ctl_candidates[@]}"; do
    [[ -x "$c" ]] && { HYDE_CTL_BIN="$c"; break; }
  done

  # Detect HyDE presence
  if [[ -d "$hyde_zsh_dir" ]]; then
    HYDE_DETECTED=true
  elif [[ -n "$HYDE_SHELL_BIN" && -d "$hyde_config_dir" ]]; then
    HYDE_DETECTED=true
  fi

  # Check for Niri compositor
  if command -v niri &>/dev/null && [[ -d "$HOME/.config/niri" || -d "/etc/niri" ]]; then
    NIRI_DETECTED=true
  fi

  # Check for DMS (Dank Material Shell) - can run alongside Hyprland or Niri
  if command -v dms-shell &>/dev/null || command -v dmsctl &>/dev/null; then
    DMS_DETECTED=true
  fi

  # Check for Noctalia - look for config directory or command
  if [[ -d "$HOME/.config/noctalia" ]] || command -v noctalia &>/dev/null; then
    NOCTALIA_DETECTED=true
  fi

  # Check for greetd - look for greetd session or command
  if command -v greetd &>/dev/null || [[ -f "/usr/bin/greetd" ]]; then
    GREETD_DETECTED=true
  fi

  # Check for plain Hyprland (NOT HyDE - HyDE takes precedence)
  # Detect if Hyprland or hyprctl command exists
  if ! $HYDE_DETECTED && (command -v Hyprland &>/dev/null || command -v hyprctl &>/dev/null); then
    HYPRLAND_DETECTED=true
  fi

  # Set COMPOSITOR based on detected compositor binary.
  # HyDE implies Hyprland — both map to COMPOSITOR=hyprland.
  if $HYDE_DETECTED || $HYPRLAND_DETECTED; then
    COMPOSITOR="hyprland"
  elif $NIRI_DETECTED; then
    COMPOSITOR="niri"
  else
    COMPOSITOR="none"
  fi

  # Log detection results
  log "Compositor: ${COMPOSITOR}"
  if $HYDE_DETECTED; then
    ok "HyDE detected"
    [[ -n "$HYDE_SHELL_BIN" ]] && log "  hyde-shell → $HYDE_SHELL_BIN"
    [[ -n "$HYDE_CTL_BIN"   ]] && log "  hydectl    → $HYDE_CTL_BIN"
    [[ -z "$HYDE_SHELL_BIN" ]] && warn "hyde-shell not found in PATH — CLI features may be limited"
  fi
  if $NIRI_DETECTED; then
    ok "Niri detected"
  fi
  if $DMS_DETECTED; then
    ok "DMS (Dank Material Shell) detected"
  fi
  if $NOCTALIA_DETECTED; then
    ok "Noctalia detected"
  fi
  if $GREETD_DETECTED; then
    ok "greetd detected"
  fi
  if $HYPRLAND_DETECTED; then
    ok "Hyprland detected"
  fi
  if [[ "$COMPOSITOR" == "none" ]]; then
    log "No compositor detected — using plain dotfiles mode"
  fi
}

# Kept for backward compatibility - wraps detect_de
detect_hyde() {
  detect_de
}

###############################################################################
# Backup helpers
###############################################################################

# backup_path PATH
#   Copies PATH → PATH.bak.<timestamp> unless PATH is already a stow symlink
#   pointing back into our dotfiles tree.
# Note: backup_hyde_zsh lives in scripts/patches/hyde.sh
backup_path() {
  local target="$1"
  [[ -e "$target" || -L "$target" ]] || return 0

  # Already one of our stow symlinks — nothing to back up
  if [[ -L "$target" ]]; then
    local real
    real="$(readlink -f "$target" 2>/dev/null || true)"
    [[ "$real" == "$DOTFILES_DIR"* ]] && return 0
  fi

  local bkp="${target}.bak.${BKP_TS}"
  log "  backup: $target → $bkp"
  run cp -a "$target" "$bkp"
  run rm -rf "$target"
}

###############################################################################
# Stow
###############################################################################

# stow_pkg PKG
#   Detects conflicts via --simulate, backs them up, then stows for real.
#   --no-folding: stow never converts a real directory into a symlink, which
#   is essential when HyDE has already populated subdirs like conf.d/.
stow_pkg() {
  local pkg="$1"
  log "Stowing: $pkg"

  if ! $DRY_RUN; then
    # Collect conflict lines from the simulate run (non-zero exit is normal
    # when there are conflicts — we catch and handle them)
    local sim_out
    sim_out="$(
      stow --simulate --no-folding \
           -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>&1
    )" || true

    # stow prints: "  * cannot stow ... over existing target PATH since neither..."
    while IFS= read -r line; do
      [[ "$line" == *"since neither a link nor a directory"* ]] || continue
      # extract the path between "existing target " and " since"
      local rel
      rel="${line#*existing target }"
      rel="${rel% since*}"
      backup_path "$HOME/$rel"
    done <<< "$sim_out"
  fi

  run stow --no-folding --override='.*' -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
}

stow_packages() {
  local -a pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    stow_pkg "$pkg"
  done
}

# stow_shell_pkg PKG
#   Stows shell-specific packages with override flag to allow overriding base/DE files
stow_shell_pkg() {
  local pkg="$1"
  log "Stowing (shell override): $pkg"

  if ! $DRY_RUN; then
    # Collect conflict lines from the simulate run
    local sim_out
    sim_out="$(
      stow --simulate --no-folding \
           --override='.*' \
           -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>&1
    )" || true

    # stow prints: "  * cannot stow ... over existing target PATH since neither..."
    while IFS= read -r line; do
      [[ "$line" == *"since neither a link nor a directory"* ]] || continue
      # extract the path between "existing target " and " since"
      local rel
      rel="${line#*existing target }"
      rel="${rel% since*}"
      backup_path "$HOME/$rel"
    done <<< "$sim_out"
  fi

  run stow --no-folding --override='.*' -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
}

# select_arch_packages - Determine which Arch stow packages to use based on COMPOSITOR
# Returns: newline-separated list of packages in correct order
select_arch_packages() {
  local -a arch_pkgs=("${ARCH_COMMON_PKGS[@]}")

  # Add compositor base package
  case "$COMPOSITOR" in
    hyprland)
      arch_pkgs+=("${ARCH_HYPRLAND_PKGS[@]}")
      # Add HyDE overlay on top if detected
      if $HYDE_DETECTED; then
        arch_pkgs+=("${ARCH_HYDE_PKGS[@]}")
      fi
      ;;
    niri)
      arch_pkgs+=("${ARCH_NIRI_PKGS[@]}")
      ;;
    none)
      ;;
  esac

  # Add shell/addon layer packages (independent of compositor)
  if $NOCTALIA_DETECTED; then
    arch_pkgs+=("${NOCTALIA_STOW_PKGS[@]}")
  fi
  if $DMS_DETECTED; then
    arch_pkgs+=("${DANK_STOW_PKGS[@]}")
  fi

  printf '%s\n' "${arch_pkgs[@]}"
}

# select_arch_pkg_files - Determine which Arch package lists to use based on COMPOSITOR
# Sets: ARCH_PKG_FILES (global array)
select_arch_pkg_files() {
  # Default: core.txt, aur.txt, work.txt
  local -a pkg_files=(core.txt aur.txt work.txt)

  case "$COMPOSITOR" in
    hyprland)
      # Base Hyprland packages
      pkg_files+=(hyprland-core.txt)
      # HyDE overlay if detected
      if $HYDE_DETECTED; then
        pkg_files+=(hyde-core.txt hyde-aur.txt)
      fi
      ;;
    niri)
      # Niri: include both niri-specific and generic packages
      pkg_files+=(niri-core.txt niri-aur.txt)
      ;;
    none)
      # No compositor: just default (already set)
      ;;
  esac

  # Add DMS-specific packages if detected (works alongside any compositor)
  if $DMS_DETECTED; then
    pkg_files+=(dank-core.txt dank-aur.txt)
  fi

  # Add Noctalia-specific AUR packages if detected (works alongside any compositor)
  if $NOCTALIA_DETECTED; then
    pkg_files+=(noctalia-aur.txt)
  fi

  ARCH_PKG_FILES=("${pkg_files[@]}")
}

unstow_all() {
  local -a all=(
    "${BASE_STOW_PKGS[@]}"
    "${MACOS_STOW_PKGS[@]}"
    "${ARCH_COMMON_PKGS[@]}"
    "${ARCH_HYPRLAND_PKGS[@]}"
    "${ARCH_HYDE_PKGS[@]}"
    "${ARCH_NIRI_PKGS[@]}"
  )
  for pkg in "${all[@]}"; do
    # Silently ignore packages that were never stowed
    run stow -D --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>/dev/null || true
  done
}

###############################################################################
# Helpers (used by scripts/patches/hyde.sh and install.sh)
###############################################################################

# _remove_from_stow PKG — removes PKG from STOW_SELECTED in-place
_remove_from_stow() {
  local remove="$1"
  local -a filtered=()
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" != "$remove" ]] && filtered+=("$pkg")
  done
  STOW_SELECTED=("${filtered[@]}")
}

# _append_if_absent FILE COMMENT LINE
#   Writes COMMENT + LINE to FILE only when LINE is not already present.
_append_if_absent() {
  local file="$1" comment="$2" line="$3"
  if $DRY_RUN; then
    log "[dry-run] would append to $(basename "$file"): $line"
    return
  fi
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -qF "$line" "$file" 2>/dev/null; then
    printf '\n%s\n%s\n' "$comment" "$line" >> "$file"
    ok "  appended to $(basename "$file"): $line"
  else
    log "  already present in $(basename "$file"): $line"
  fi
}

###############################################################################
# Homebrew
###############################################################################

brew_install() {
  local file="$1"
  log "Brew bundle: $file"
  run brew bundle --file="$DOTFILES_DIR/homebrew/$file"
}

###############################################################################
# Arch packages
###############################################################################

arch_install() {
  local file="$1"
  local pkg_file="$DOTFILES_DIR/arch-pkgs/$file"

  if [[ ! -f "$pkg_file" ]]; then
    err "Package file not found: $pkg_file"
    return 1
  fi

  # Build package array — skip blank lines and comments
  local -a pkgs=()
  while IFS= read -r line; do
    line="${line%%#*}"      # strip inline comments
    line="${line//[[:space:]]/}"  # strip whitespace
    [[ -n "$line" ]] && pkgs+=("$line")
  done < "$pkg_file"

  if (( ${#pkgs[@]} == 0 )); then
    warn "No packages in $file — skipping"
    return
  fi

  # Remove known conflicting packages before installing
  for entry in "${ARCH_CONFLICTS[@]:-}"; do
    local our_pkg="${entry%%:*}"
    local conflict_pkg="${entry##*:}"
    # Only act if our package is in this batch and the conflict is installed
    if printf '%s\n' "${pkgs[@]}" | grep -qx "$our_pkg"; then
      local installed_name
      installed_name="$(pacman -Qq "$conflict_pkg" 2>/dev/null || true)"
      if [[ -n "$installed_name" && "$installed_name" != "$our_pkg" ]]; then
        log "Removing conflicting package: $conflict_pkg (conflicts with $our_pkg)"
        run sudo pacman -Rns --noconfirm "$conflict_pkg" || \
          run yay -Rns --noconfirm "$conflict_pkg" || \
          warn "Could not remove $conflict_pkg — you may need to remove it manually"
      fi
    fi
  done

  log "Installing ${#pkgs[@]} packages from $file"
  run yay -S --needed --noconfirm "${pkgs[@]}"
}

###############################################################################
# Gitconfig
###############################################################################

install_gitconfig_task() {
  step "Gitconfig"
  local src="$DOTFILES_DIR/.gitconfig"
  local dest="$HOME/.gitconfig"

  backup_path "$dest"
  run cp "$src" "$dest"

  if $DRY_RUN; then
    log "[dry-run] would prompt for git user.name / user.email"
    return
  fi

  require_gum
  local git_name git_email
  git_name=$(gum input --placeholder="git user.name" || true)
  git_email=$(gum input --placeholder="git user.email" || true)

  if [[ -n "$git_name" ]]; then
    git config --file "$dest" user.name "$git_name"
  fi
  if [[ -n "$git_email" ]]; then
    git config --file "$dest" user.email "$git_email"
  fi
  ok "gitconfig written"

  # Track selection
  update_selection "gitconfig" "user"
}

###############################################################################
# Post-install
###############################################################################

# get_available_patches
#   Returns list of available patch files based on OS filter only.
#   Patch scripts self-guard with internal detection checks.
get_available_patches() {
  local -a available=()

  for patch in "${!PATCH_FILES[@]}"; do
    local def="${PATCH_FILES[$patch]}"
    local os_filter="${def#*:}"

    # Check OS filter only
    local os_match=false
    case "$os_filter" in
      all) os_match=true ;;
      arch) [[ "$OS" == "arch" || "$OS" == "cachyos" ]] && os_match=true ;;
      macos) [[ "$OS" == "macos" ]] && os_match=true ;;
    esac

    $os_match && available+=("$patch")
  done

  # Sort patches in desired order
  local -a desired_order=(common hyprland niri noctalia dank hyde)
  local -a sorted=()
  for patch in "${desired_order[@]}"; do
    for avail in "${available[@]}"; do
      [[ "$avail" == "$patch" ]] && sorted+=("$avail") && break
    done
  done
  # Add any patches not in desired_order
  for avail in "${available[@]}"; do
    local found=false
    for patch in "${sorted[@]}"; do
      [[ "$avail" == "$patch" ]] && found=true && break
    done
    $found || sorted+=("$avail")
  done

  printf '%s\n' "${sorted[@]}"
}

# get_patch_functions PATCH_NAME
#   Returns list of individual functions available in a patch file
get_patch_functions() {
  local patch="$1"

  # Validate patch exists in PATCH_FILES before proceeding
  [[ -z "${PATCH_FILES[$patch]:-}" ]] && return 1

  local func_str="${PATCH_FUNCTIONS[$patch]:-}"
  if [[ -z "$func_str" ]]; then
    # Fallback: try to source and list functions
    local script="${PATCH_FILES[$patch]%%:*}"
    if [[ -f "$DOTFILES_DIR/$script" ]]; then
      # shellcheck source=scripts/patches/common.sh
      source "$DOTFILES_DIR/$script"
      func_str="$(declare -F | grep -E "^declare -f (install_|reload_|apply_|remind_|backup_|hyde_)" | sed 's/declare -f //' | grep "^${patch}_" || true)"
    fi
  fi
  # Use awk to split on whitespace - works in both bash and zsh
  # This ensures each function name is on its own line
  if [[ -n "$func_str" ]]; then
    printf '%s\n' "$func_str" | awk '{for(i=1;i<=NF;i++) print $i}'
  fi
}

# get_patch_function_choices PATCH_NAME
#   Returns list of "func_name: description" for interactive selection
#   Adds "(last applied: ...)" if previously selected
get_patch_function_choices() {
  local patch="$1"
  local func_str="${PATCH_FUNCTIONS[$patch]:-}"

  if [[ -z "$func_str" ]]; then
    return
  fi

  # Split function names
  local -a funcs
  func_str=$(printf '%s\n' "$func_str" | awk '{for(i=1;i<=NF;i++) print $i}')
  mapfile -t funcs < <(printf '%s\n' "$func_str")

  # Output each with description and last applied timestamp
  for f in "${funcs[@]}"; do
    local choice="$f"
    local desc="${PATCH_FUNCTION_DESCRIPTIONS[$f]:-}"
    if [[ -n "$desc" ]]; then
      choice="$choice: $desc"
    fi
    # Add last applied timestamp
    choice=$(apply_selection_label "patches" "$f" "$choice")
    printf '%s\n' "$choice"
  done
}

# run_patch PATCH_NAME [FUNC1 FUNC2 ...]
#   Sources patch file and runs specified functions (or all if none specified)
run_patch() {
  local patch="$1"
  shift
  local -a selected_funcs=("$@")

  local def="${PATCH_FILES[$patch]:-}"
  [[ -z "$def" ]] && { warn "Unknown patch: $patch"; return 1; }

  local script="${def%%:*}"
  local script_path="$DOTFILES_DIR/$script"
  [[ -f "$script_path" ]] || { warn "Patch script not found: $script_path"; return 1; }

  # Source the patch file
  # Export functions and variables needed by patch scripts
  export -f require_gum interactive_select log warn ok step run 2>/dev/null || true
  export DRY_RUN INTERACTIVE DOTFILES_DIR COMPOSITOR GREETD_DETECTED 2>/dev/null || true
  # shellcheck source=scripts/patches/common.sh
  source "$script_path"

  # Get all available functions for this patch if none specified
  local -a funcs_to_run=()
  if (( ${#selected_funcs[@]} == 0 )); then
    # Use get_patch_functions which handles word splitting correctly
    mapfile -t funcs_to_run < <(get_patch_functions "$patch")
  else
    funcs_to_run=("${selected_funcs[@]}")
  fi

  # Run each function
  for func in "${funcs_to_run[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
      log "  → running: $func"
      "$func"
    else
      warn "  ✗ function not found: $func"
    fi
  done
}

post_install_task() {
  step "Post-install"

  # Get available patch files based on OS and detected DE/shell
  local -a available_patches
  mapfile -t available_patches < <(get_available_patches)

  if (( ${#available_patches[@]} == 0 )); then
    log "No patches available for this configuration — skipping"
    return
  fi

  # First level: select which patch groups to apply
  local -a selected_patches=()

  if (( ${#PATCHES_SELECTED[@]} > 0 )); then
    # Explicit patches passed via --patches flag
    for p in "${PATCHES_SELECTED[@]}"; do
      local valid=false
      for av in "${available_patches[@]}"; do
        [[ "$p" == "$av" ]] && valid=true && break
      done
      if $valid; then
        selected_patches+=("$p")
      else
        warn "Skipping unavailable patch group: $p"
      fi
    done
  elif $INTERACTIVE; then
    log "Select patch groups to apply:"

    # Build patch group choices (add last applied timestamp if previously selected)
    local -a patch_choices=()
    for p in "${available_patches[@]}"; do
      local label="$p"
      local w; w="$(get_patch_warning "$p")"
      if [[ -n "$w" ]]; then
        label="$label  ⚠ $w"
      fi
      label=$(apply_selection_label "patches" "$p" "$label")
      patch_choices+=("$label")
    done

    local sel
    sel="$(interactive_select --exit "${patch_choices[@]}")" || true

    if [[ -n "$sel" ]]; then
      while IFS= read -r item; do
        [[ -n "$item" ]] && selected_patches+=("$(strip_label "$item")")
      done <<< "$sel"
    fi
  else
    # Non-interactive: include all available patches
    selected_patches=("${available_patches[@]}")
  fi

  if (( ${#selected_patches[@]} == 0 )); then
    log "No patch groups selected — skipping post-install"
    return
  fi

  # Second level: for each selected patch group, select which functions to run
  local -a all_runs=()  # Format: "patch:func"

  if $INTERACTIVE; then
    for patch in "${selected_patches[@]}"; do
      # Get functions using while read (works in both bash and zsh)
      # Don't use local on funcs - causes issues with array access
      local -a funcs
      funcs=()
      while IFS= read -r f; do
        [[ -n "$f" ]] && funcs+=("$f")
      done < <(get_patch_functions "$patch")

      if (( ${#funcs[@]} == 0 )); then
        warn "No functions defined for patch: $patch"
        continue
      fi

      if (( ${#funcs[@]} == 1 )); then
        # Single function - auto-select
        # Build entry directly without local storage
        all_runs+=("$patch:${funcs[0]}")
        log "  $patch: auto-selecting ${funcs[0]}"
      else
        # Get choices with descriptions
        local -a choices=()
        while IFS= read -r c; do
          [[ -n "$c" ]] && choices+=("$c")
        done < <(get_patch_function_choices "$patch")

        log "Select functions for $patch:"
        local sel
        sel="$(interactive_select --exit "${choices[@]}")" || true

        if [[ -n "$sel" ]]; then
          while IFS= read -r c; do
            [[ -n "$c" ]] || continue
            # Extract function name - strip label first
            local func_name
            func_name=$(strip_label "$c")
            # Extract just the function name (before any colon in original)
            func_name="${func_name%%:*}"
            all_runs+=("$patch:$func_name")
          done <<< "$sel"
        fi
      fi
    done
  else
    # Non-interactive: run all functions from each selected patch
    for patch in "${selected_patches[@]}"; do
      local -a funcs
      funcs=()
      while IFS= read -r f; do
        [[ -n "$f" ]] && funcs+=("$f")
      done < <(get_patch_functions "$patch")
      for f in "${funcs[@]}"; do
        all_runs+=("$patch:$f")
      done
    done
  fi

  if (( ${#all_runs[@]} == 0 )); then
    log "No functions selected — skipping post-install"
    return
  fi

  # Run selected patches with their functions
  log "Running ${#all_runs[@]} patch function(s)..."
  for run in "${all_runs[@]}"; do
    local patch="${run%%:*}"
    local func="${run#*:}"
    run_patch "$patch" "$func"
  done

  # Track patch group and function selections
  for p in "${selected_patches[@]}"; do
    update_selection "patches" "$p"
  done

  # Track individual functions (sub-selections)
  for run in "${all_runs[@]}"; do
    local patch="${run%%:*}"
    local func="${run#*:}"
    update_selection "patches" "$func"
  done
}

###############################################################################
# Task queue
###############################################################################

register_task() { [[ -n "$1" ]] && TASKS+=("$1"); }

execute_tasks() {
  for task in "${TASKS[@]:-}"; do
    [[ -z "$task" ]] && continue
    "$task"
  done
}

###############################################################################
# Task wrappers — called by name via execute_tasks
###############################################################################

stow_selected() {
  step "Stow"

  # Back up HyDE's zsh files before stow can overwrite them
  if $HYDE_DETECTED; then
    local stowing_zsh=false
    for pkg in "${STOW_SELECTED[@]:-}"; do
      [[ "$pkg" == "zsh" ]] && stowing_zsh=true && break
    done
    if $stowing_zsh; then
      step "Backing up HyDE zsh files"
      backup_hyde_zsh
    fi
  fi

  # Separate regular packages from shell packages and optional packages
  local -a regular_pkgs=()
  local -a shell_pkgs=()
  local -a optional_pkgs=()

  for pkg in "${STOW_SELECTED[@]:-}"; do
    # Check if it's a shell-specific package
    if [[ " ${NOCTALIA_STOW_PKGS[*]} ${DANK_STOW_PKGS[*]} " == *" $pkg "* ]]; then
      shell_pkgs+=("$pkg")
      # Check if it's an optional package (should be stowed last)
    elif [[ " ${OPTIONAL_STOW_PKGS[*]} " == *" $pkg "* ]]; then
      optional_pkgs+=("$pkg")
    else
      regular_pkgs+=("$pkg")
    fi
  done

  # Stow regular packages first (base, DE/WM)
  if (( ${#regular_pkgs[@]} > 0 )); then
    stow_packages "${regular_pkgs[@]}"
  fi

  # Stow shell packages with override capability
  if (( ${#shell_pkgs[@]} > 0 )); then
    for pkg in "${shell_pkgs[@]}"; do
      stow_shell_pkg "$pkg"
    done
  fi

  # Stow optional packages last (can override earlier files)
  if (( ${#optional_pkgs[@]} > 0 )); then
    for pkg in "${optional_pkgs[@]}"; do
      stow_shell_pkg "$pkg"
    done
  fi

  # Apply starship mode only if starship was selected
  local starship_selected=false
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" == "starship" ]] && starship_selected=true && break
  done

  if $starship_selected && $HYDE_DETECTED; then
    apply_starship_mode
  fi

  # Patch HyDE's user.zsh and plugin.zsh (idempotent, in scripts/patches/hyde.sh)
  if $HYDE_DETECTED; then
    patch_user_zsh
    patch_plugin_zsh
    ensure_hyde_completions
  fi

  # Track selections
  for pkg in "${STOW_SELECTED[@]:-}"; do
    update_selection "stows" "$pkg"
  done
}

brew_selected() {
  step "Homebrew"
  for f in "${BREW_SELECTED[@]:-}"; do
    brew_install "$f"
  done

  # Track selections
  for f in "${BREW_SELECTED[@]:-}"; do
    update_selection "pkgs" "$f"
  done
}

arch_selected() {
  step "Arch packages"
  for f in "${ARCH_SELECTED[@]:-}"; do
    arch_install "$f"
  done

  # Track selections
  for f in "${ARCH_SELECTED[@]:-}"; do
    update_selection "pkgs" "$f"
  done
}

###############################################################################
# Dry-run summary
###############################################################################

dry_run_summary() {
  ! $DRY_RUN && return

  step "Dry Run Summary"

  printf "  OS: %s (distro: %s)\n" "$OS" "${DISTRO_ID:-unknown}"
  printf "  Compositor: %s\n" "${COMPOSITOR:-none}"
  printf "  HyDE detected: %s\n" "$HYDE_DETECTED"
  printf "  Niri detected: %s\n" "$NIRI_DETECTED"
  printf "  DMS detected: %s\n" "$DMS_DETECTED"
  printf "  Noctalia detected: %s\n" "$NOCTALIA_DETECTED"
  printf "  greetd detected: %s\n" "$GREETD_DETECTED"

  # Starship context
  local starship_selected=false
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" == "starship" ]] && starship_selected=true && break
  done

  if $starship_selected; then
    printf "  Starship mode: %s\n" "$STARSHIP_MODE"
  fi

  # Backup location (only relevant when HyDE + zsh involved)
  local zsh_selected=false
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" == "zsh" ]] && zsh_selected=true && break
  done

  if $HYDE_DETECTED && $zsh_selected; then
    local bkp_root="$HOME/.local/share/neo-dots/hyde-bkp/$BKP_TS"
    printf "\n  HyDE zsh backups will be stored in:\n"
    printf "    %s\n" "$bkp_root"
  fi

  # Stow
  if (( ${#STOW_SELECTED[@]} > 0 )); then
    printf "\n  Stow packages:\n"
    # Show in order: base, DE/WM, then shell
    for pkg in "${STOW_SELECTED[@]}"; do
      if [[ " ${NOCTALIA_STOW_PKGS[*]} ${DANK_STOW_PKGS[*]} " == *" $pkg "* ]]; then
        printf "    - %s (with override)\n" "$pkg"
      elif [[ " ${OPTIONAL_STOW_PKGS[*]} " == *" $pkg "* ]]; then
        printf "    - %s (optional, may override)\n" "$pkg"
      else
        printf "    - %s\n" "$pkg"
      fi
    done
  fi

  # Brew
  if (( ${#BREW_SELECTED[@]} > 0 )); then
    printf "\n  Brew bundles:\n"
    for f in "${BREW_SELECTED[@]}"; do
      printf "    - %s\n" "$f"
    done
  fi

  # Arch
  if (( ${#ARCH_SELECTED[@]} > 0 )); then
    printf "\n  Arch package lists:\n"
    for f in "${ARCH_SELECTED[@]}"; do
      printf "    - %s\n" "$f"
    done
  fi

  # Additional tasks
  local has_extra=false
  for t in "${TASKS[@]:-}"; do
    case "$t" in
      install_gitconfig_task|post_install_task) has_extra=true; break ;;
    esac
  done

  if $has_extra; then
    printf "\n  Additional tasks:\n"
    for t in "${TASKS[@]:-}"; do
      case "$t" in
        install_gitconfig_task) printf "    • install gitconfig\n" ;;
        post_install_task)      printf "    • run post-install (TPM, HyDE reload)\n" ;;
        hyde_seed_config)       printf "    • seed HyDE config.toml (preserve-if-absent)\n" ;;
      esac
    done
  fi

  printf "\n"
}

###############################################################################
# Interactive helpers (using gum)
###############################################################################

# require_gum - Check if gum is installed, offer to bootstrap if missing
require_gum() {
  if ! command -v gum &>/dev/null; then
    err "gum is required but not installed."
    echo ""
    read -p "Run bootstrap to install dependencies? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
      # Ensure bootstrap.sh is sourced (in case require_gum called before main)
      if ! declare -f install_deps &>/dev/null; then
        # shellcheck source=bootstrap.sh
        source "$DOTFILES_DIR/scripts/bootstrap.sh"
      fi
      log "Running bootstrap..."
      if install_deps; then
        ok "Bootstrap complete"
      else
        err "Bootstrap failed. Please install gum manually:"
        err "  Arch:     yay -S gum stow"
        err "  macOS:    brew install gum stow"
        err "  Or see:   https://github.com/charmbracelet/gum"
        exit 1
      fi
    else
      err "gum is required to continue."
      err "Install it from: https://github.com/charmbracelet/gum"
      exit 1
    fi
  fi
}

# interactive_select ITEM...
#   Prints selected items to stdout, one per line.
#   Uses gum choose --no-limit for multi-selection.
#   Returns empty if user presses Escape or Ctrl+C (to skip).
#   Shows exit option if can_exit=true.
interactive_select() {
  require_gum
  local can_exit="false"

  # Check if first arg is "--exit" flag
  if [[ "${1:-}" == "--exit" ]]; then
    can_exit="true"
    shift
  fi

  local items=("$@")

  # Temporarily enable exit on error to catch gum's exit codes
  (
    set +e  # Disable exit-on-error inside subshell
    local result
    result=$(printf '%s\n' "${items[@]}" | gum choose --no-limit --header="Select items (Space to toggle, Enter to confirm):")
    local exit_code=$?

    # If exit code is 130 (Escape/Ctrl+C), show exit prompt
    if [[ $exit_code -eq 130 ]]; then
      if [[ "$can_exit" == "true" ]]; then
        local exit_choice
        exit_choice=$(printf '%s\n' "Skip this step" "Exit installer" | gum choose --header="What would you like to do?" || true)

        if [[ "$exit_choice" == "Exit installer" ]]; then
          printf '\n  ➜ Exiting installer.\n\n'
          exit 130
        fi
      fi
    fi

    printf '%s' "$result"
  )
}

# interactive_choose ITEM...
#   Single selection (radio style) using gum.
#   Returns the selected item or empty if cancelled (Escape/Ctrl+C).
interactive_choose() {
  require_gum
  local items=("$@")
  local result
  result=$(printf '%s\n' "${items[@]}" | gum choose --header="Select an option:" || true)
  printf '%s' "$result"
}

# interactive_confirm MESSAGE
#   Returns 0 (true) if user confirms, 1 (false) if not.
#   Default is "No" - user must explicitly confirm.
#   Second arg: if "true", pressing No/Escape will exit the entire script
interactive_confirm() {
  local msg="${1:-Continue?}"
  local can_exit="${2:-false}"
  require_gum

  local exit_code=0
  local result

  # Run gum and capture both result and exit code properly
  result=$(gum confirm --default "$msg") || exit_code=$?

  # Exit code 0 = Yes, 1 = No, 130 = Ctrl+C/Escape
  if [[ $exit_code -eq 0 ]]; then
    return 0  # Yes selected
  fi

  # No/Escape/Ctrl+C pressed
  printf '\n'
  if [[ "$can_exit" == "true" ]]; then
    printf '  ➜ Exiting installer.\n\n'
    exit 0
  else
    # For subsequent prompts, ask if they want to exit or skip
    local exit_choice
    exit_choice=$(printf '%s\n' "Skip this step" "Exit installer" | gum choose --header="What would you like to do?" || true)

    if [[ "$exit_choice" == "Exit installer" ]]; then
      printf '  ➜ Exiting installer.\n\n'
      exit 0
    fi
    # Otherwise skip (return 1)
  fi
  return 1  # Skip this step
}

# make_labeled_item ITEM REQUIRES_MAP_NAME
#   Produces a display label for use in gum choosers.
#   Appends "  ⚠ <label> not detected" if required dependency is unmet.
#   REQUIRES_MAP_NAME: name of an associative array (passed by name, not value)
#   Format of map values: "VAR_NAME:expected_value:display_label"
#   Special case: VAR_NAME="COMPOSITOR" compares against $COMPOSITOR
make_labeled_item() {
  local item="$1"
  local map_name="$2"
  local -n _req_map="$map_name"

  local req="${_req_map[$item]:-}"
  if [[ -z "$req" ]]; then
    printf '%s' "$item"
    return
  fi

  local var_name="${req%%:*}"
  local rest="${req#*:}"
  local expected="${rest%%:*}"
  local display_label="${rest##*:}"

  local actual_value
  if [[ "$var_name" == "COMPOSITOR" ]]; then
    actual_value="$COMPOSITOR"
  else
    actual_value="${!var_name}"   # indirect expansion of boolean flag
  fi

  if [[ "$actual_value" == "$expected" ]]; then
    printf '%s' "$item"
  else
    printf '%s  ⚠ %s not detected' "$item" "$display_label"
  fi
}

# strip_label ITEM
#   Removes "  ⚠ ..." and " (last applied: ...)" suffixes.
strip_label() {
  local out="$1"
  out="${out%%  ⚠*}"
  out="${out%%  (last applied:*}"
  printf '%s' "$out"
}

# Selection tracking file
SELECTIONS_FILE="$HOME/.local/state/dotfiles_selections.conf"
mkdir -p "$(dirname "$SELECTIONS_FILE")"

# read_selections SECTION
#   Reads timestamps from a section in the selections file.
#   Returns: key=value lines for each recorded selection.
read_selections() {
  local section="$1"
  [[ -f "$SELECTIONS_FILE" ]] || return 0
  awk -F' = ' -v section="$section" '
    /^\[.*\]$/ { in_section=($0 == "["section"]") }
    in_section && NF == 2 { print }
  ' "$SELECTIONS_FILE" 2>/dev/null
}

# get_selection_timestamp SECTION KEY
#   Returns timestamp for a specific selection, empty if not found.
get_selection_timestamp() {
  local section="$1"
  local key="$2"
  read_selections "$section" | awk -F' = ' -v key="$key" '$1 == key { print $2; exit }'
}

# update_selection SECTION KEY [TIMESTAMP]
#   Updates (or adds) a selection with current timestamp.
#   Uses INI-style format in selections file.
update_selection() {
  local section="$1"
  local key="$2"
  local timestamp="${3:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

  local new_ts
  new_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  local tmp="${SELECTIONS_FILE}.tmp"

  {
    echo "# dotfiles_selections"
    echo "# Updated: $new_ts"
    echo ""
  } > "$tmp"

  local in_target=false
  local key_done=false

  if [[ -f "$SELECTIONS_FILE" ]]; then
    while IFS= read -r line; do
      # Header/blank
      [[ "$line" == "#"* ]] && continue
      [[ -z "$line" ]] && continue

      # Section header like [stows]
      if [[ "$line" == "["*"]" ]]; then
        # Leaving target section?
        if $in_target && ! $key_done; then
          echo "$key = $timestamp" >> "$tmp"
          key_done=true
        fi
        # Check if this is our target section
        in_target=false
        [[ "$line" == "[$section]" ]] && in_target=true
        echo "$line" >> "$tmp"
        # Key=Value line
      elif [[ "$line" == *" = "* ]]; then
        local k="${line%% = *}"
        [[ "$k" == "$key" ]] && continue  # Skip old key
        echo "$line" >> "$tmp"
      else
        echo "$line" >> "$tmp"
      fi
    done < "$SELECTIONS_FILE"

    # File end - if in target and haven't added
    if $in_target && ! $key_done; then
      echo "$key = $timestamp" >> "$tmp"
      key_done=true
    fi
  fi

  # New section/file
  if ! $key_done; then
    echo "[$section]" >> "$tmp"
    echo "$key = $timestamp" >> "$tmp"
  fi

  mv -f "$tmp" "$SELECTIONS_FILE"
}

# apply_selection_label SECTION KEY LABEL
#   Appends "(last applied: MMM DD YYYY)" to LABEL if selection exists.
#   Returns the modified label.
apply_selection_label() {
  local section="$1"
  local key="$2"
  local label="$3"

  # Strip any existing last applied first (avoid double append)
  label="${label%%  (last applied:*}"

  local ts
  ts=$(get_selection_timestamp "$section" "$key")

  if [[ -n "$ts" ]]; then
    # Parse ISO timestamp to human readable
    local date_str
    date_str=$(date -d "${ts%Z}" +"%b %d %Y" 2>/dev/null || printf '%s' "$ts")
    printf '%s  (last applied: %s)' "$label" "$date_str"
  else
    printf '%s' "$label"
  fi
}

# get_patch_warning PATCH_NAME
#   Returns a warning string if a patch's DE dependency is unmet, empty otherwise.
#   Matches by patch name (not PATCH_FILES entry which no longer has de_filter).
get_patch_warning() {
  local patch="$1"

  case "$patch" in
    hyprland)
      if [[ "$COMPOSITOR" != "hyprland" ]]; then
        printf 'Hyprland not detected'
      fi
      ;;
    hyde)
      if $HYDE_DETECTED; then :; else printf 'HyDE not detected'; fi
      ;;
    niri)
      if $NIRI_DETECTED; then :; else printf 'Niri not detected'; fi
      ;;
    dank)
      if $DMS_DETECTED; then :; else printf 'DMS not detected'; fi
      ;;
    noctalia)
      if $NOCTALIA_DETECTED; then :; else printf 'Noctalia not detected'; fi
      ;;
  esac
}

# interactive_input PROMPT [DEFAULT]
#   Prompts for text input using gum.
#   Returns the input value (or default if empty).
interactive_input() {
  local prompt="$1"
  local default="${2:-}"
  require_gum
  gum input --value="$default" --placeholder="$prompt" || true
}

###############################################################################
# Interactive mode
###############################################################################

interactive_mode() {
  step "Interactive mode"

  # Show welcome and instructions
  printf '\n'
  printf '  Welcome to neo-dots installer!\n'
  printf '  • Press Escape to skip/close any prompt without selecting\n'
  printf '  • Use arrow keys or vim keys (j/k) to navigate\n'
  printf '  • Space to toggle, Enter to confirm\n'
  printf '  • Press Ctrl+C anytime to cancel entire installation\n\n'

  interactive_confirm "Start installation?" true

  # In dry-run we skip prompts and simulate a full run
  if $DRY_RUN; then
    warn "Dry-run: registering all tasks (no prompts)"
    STOW_SELECTED=("${BASE_STOW_PKGS[@]}")
    [[ "$OS" == "macos" ]] && STOW_SELECTED+=("${MACOS_STOW_PKGS[@]}")
    if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
      mapfile -t STOW_SELECTED_ARCH < <(select_arch_packages)
      STOW_SELECTED+=("${STOW_SELECTED_ARCH[@]}")
    fi
    register_task "stow_selected"
    if [[ "$OS" == "macos" ]]; then
      BREW_SELECTED=("${BREW_FILES[@]}")
      register_task "brew_selected"
    elif [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
      ARCH_SELECTED=("${ARCH_PKG_FILES[@]}")
      register_task "arch_selected"
    fi
    STARSHIP_MODE="dotfiles"
    register_task "install_gitconfig_task"
    register_task "post_install_task"
    return
  fi

  # ── Stow packages ─────────────────────────────────────────────────────────
  # Build the list of available stow packages based on OS and detected WM/Shell
  local -a all_stow=("${BASE_STOW_PKGS[@]}")
  [[ "$OS" == "macos" ]] && all_stow+=("${MACOS_STOW_PKGS[@]}")

  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    # Always include arch-common for Arch/CachyOS
    all_stow+=("${ARCH_COMMON_PKGS[@]}")

    # Add compositor base packages (all shown, warnings added later)
    all_stow+=(
      "${ARCH_HYPRLAND_PKGS[@]}"
      "${ARCH_HYDE_PKGS[@]}"
      "${ARCH_NIRI_PKGS[@]}"
    )

    # Add shell-specific packages (shown always, warnings for missing deps)
    all_stow+=(
      "${NOCTALIA_STOW_PKGS[@]}"
      "${DANK_STOW_PKGS[@]}"
    )

    # Add optional packages (available on any OS)
    all_stow+=("${OPTIONAL_STOW_PKGS[@]}")

    printf '\n'
  fi

  # Build labeled items (add last applied timestamp if previously selected)
  local -a labeled_stow=()
  for pkg in "${all_stow[@]}"; do
    local label
    label=$(make_labeled_item "$pkg" STOW_PKG_REQUIRES)
    label=$(apply_selection_label "stows" "$pkg" "$label")
    labeled_stow+=("$label")
  done

  printf '\n'
  log "Packages marked ⚠ have unmet dependencies but can still be selected."
  local sel
  sel="$(interactive_select --exit "${labeled_stow[@]}")" || true

  if [[ -n "$sel" ]]; then
    while IFS= read -r item; do
      [[ -n "$item" ]] && STOW_SELECTED+=("$(strip_label "$item")")
    done <<< "$sel"

    # ── Starship mode (only if starship selected and HyDE present) ──────────
    local starship_selected=false
    for pkg in "${STOW_SELECTED[@]}"; do
      [[ "$pkg" == "starship" ]] && starship_selected=true && break
    done

    if $starship_selected && $HYDE_DETECTED; then
      prompt_starship_mode
    fi

    register_task "stow_selected"
  else
    log "Skipping stow"
    printf '\n'
  fi

  # ── OS-specific packages ───────────────────────────────────────────────────
  if [[ "$OS" == "macos" ]]; then
    printf '\n'
    log "Select Brewfiles to install:"
    local bsel
    bsel="$(interactive_select --exit "${BREW_FILES[@]}")" || true
    if [[ -n "$bsel" ]]; then
      while IFS= read -r f; do
        [[ -n "$f" ]] && BREW_SELECTED+=("$f")
      done <<< "$bsel"
      register_task "brew_selected"
    else
      log "Skipping Homebrew"
    fi
  fi

  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    log "Select Arch package lists to install:"
    log "Lists marked ⚠ have unmet dependencies but can still be selected."

    # Build labeled items from full package file list (add last applied timestamp)
    local -a labeled_pkg_files=()
    for f in "${ARCH_PKG_FILES_ALL[@]}"; do
      local label
      label=$(make_labeled_item "$f" PKG_FILE_REQUIRES)
      label=$(apply_selection_label "pkgs" "$f" "$label")
      labeled_pkg_files+=("$label")
    done

    local asel
    asel="$(interactive_select --exit "${labeled_pkg_files[@]}")" || true
    if [[ -n "$asel" ]]; then
      while IFS= read -r item; do
        [[ -n "$item" ]] && ARCH_SELECTED+=("$(strip_label "$item")")
      done <<< "$asel"
      register_task "arch_selected"
    else
      log "Skipping Arch packages"
      printf '\n'
    fi
  fi

  # ── Optional tasks ─────────────────────────────────────────────────────────
  printf '\n'

  # Check if gitconfig was previously applied
  local git_label="Install gitconfig?"
  git_label=$(apply_selection_label "gitconfig" "user" "$git_label")
  if interactive_confirm "$git_label"; then
    register_task "install_gitconfig_task"
  fi

  if interactive_confirm "Run post-install tasks (TPM, HyDE reload)?"; then
    register_task "post_install_task"
  fi

  # HyDE config.toml seed (arch/cachyos + HyDE only, automatic — no prompt needed)
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]] && $HYDE_DETECTED; then
    register_task "hyde_seed_config"
  fi
}

###############################################################################
# Argument parsing
###############################################################################

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        ;;
      --uninstall)
        UNINSTALL=true
        ;;
      --interactive)
        INTERACTIVE=true
        ;;
      --gitconfig)
        register_task "install_gitconfig_task"
        ;;
      --post-install)
        register_task "post_install_task"
        ;;
      --patches)
        shift
        if [[ -z "${1:-}" ]]; then
          err "--patches requires patch name(s) (comma-separated)"
          exit 1
        fi
        IFS=',' read -r -a _patches <<< "$1"
        PATCHES_SELECTED+=("${_patches[@]}")
        register_task "post_install_task"
        ;;
      --stow)
        shift
        if [[ -z "${1:-}" ]]; then
          err "--stow requires a package name (or comma-separated list)"
          exit 1
        fi
        IFS=',' read -r -a _pkgs <<< "$1"
        STOW_SELECTED+=("${_pkgs[@]}")
        register_task "stow_selected"
        ;;
      --starship-mode)
        shift
        case "${1:-}" in
          dotfiles|hyde|env)
            STARSHIP_MODE="$1"
            ;;
          *)
            err "--starship-mode must be one of: dotfiles, hyde, env"
            exit 1
            ;;
        esac
        ;;
      --help|-h)
        cat <<EOF
Usage: ./install.sh [OPTIONS]

  (no args)               Interactive mode — choose what to install
  --interactive           Explicit interactive mode
  --dry-run               Print actions without executing them
  --uninstall             Unstow all packages
  --stow PKG[,…]          Stow specific package(s) and exit
  --starship-mode MODE    Starship mode when HyDE is present: dotfiles|hyde|env
                          (skips the interactive prompt)
  --gitconfig             Install .gitconfig only
  --post-install          Run post-install tasks only (TPM, HyDE reload)
  --patches PATCH[,…]     Run specific patch(es) (comma-separated)
  --help                  This help

HyDE integration
  Detected automatically via \$PATH or ~/.config/hyde.
  When present the installer backs up HyDE-owned files before stowing,
  preserves hyde-shell/hydectl CLI completions, and prompts for how
  Starship should be configured (see header comment for mode details).
  HyDE's conf.d/hyde/ directory and 00-hyde.zsh are never touched.

Starship modes (only asked when HyDE is present)
  1) dotfiles  Stow our starship.toml; set HYDE_ZSH_PROMPT=0 in user.zsh
  2) hyde      Skip stowing starship/; HyDE manages starship completely
  3) env       Custom STARSHIP_CONFIG path; set HYDE_ZSH_PROMPT=0
EOF
        exit 0
        ;;
      *)
        err "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
  done
}

###############################################################################
# Default (non-interactive) base install
###############################################################################

default_base() {
  step "Default base install"
  STOW_SELECTED=("${BASE_STOW_PKGS[@]}")
  [[ "$OS" == "macos" ]] && STOW_SELECTED+=("${MACOS_STOW_PKGS[@]}")
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    mapfile -t STOW_SELECTED_ARCH < <(select_arch_packages)
    STOW_SELECTED+=("${STOW_SELECTED_ARCH[@]}")
  fi

  if $HYDE_DETECTED; then
    warn "HyDE detected in non-interactive mode."
    warn "Defaulting starship mode to 'dotfiles' (HYDE_ZSH_PROMPT=0 will be written)."
    warn "Run interactively to choose a different mode: ./install.sh"
  fi

  stow_selected

  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]] && $HYDE_DETECTED; then
    register_task "hyde_seed_config"
  fi
}

###############################################################################
# Main
###############################################################################

main() {
  local -a original_args=("$@")

  # Source bootstrap for dependency installation and shared detection
  # This gives us detect_os() and install_deps() functions
  # shellcheck source=bootstrap.sh
  source "$DOTFILES_DIR/scripts/bootstrap.sh"

  detect_os
  detect_de

  # Build dynamic ARCH_PKG_FILES based on detected WM
  if [[ "$OS" == "arch" || "$OS" == "cachyos" ]]; then
    select_arch_pkg_files
  fi

  # Log final detection state
  log "Distro: ${DISTRO_ID:-${OS}}, Compositor: ${COMPOSITOR}"

  # Source HyDE-specific patches when HyDE is present
  if $HYDE_DETECTED; then
    local patches="$DOTFILES_DIR/scripts/patches/hyde.sh"
    if [[ -f "$patches" ]]; then
      # shellcheck source=scripts/patches/hyde.sh
      source "$patches"
    else
      warn "scripts/patches/hyde.sh not found — HyDE patches unavailable"
    fi
  fi

  parse_args "$@"

  # Non-interactive starship hardening
  if ! $INTERACTIVE && $HYDE_DETECTED; then
    local starship_selected=false
    for pkg in "${STOW_SELECTED[@]:-}"; do
      [[ "$pkg" == "starship" ]] && starship_selected=true && break
    done

    if $starship_selected && [[ "$STARSHIP_MODE" == "dotfiles" ]]; then
      # Only warn if the mode wasn't explicitly set via --starship-mode
      # (dotfiles is both the default and a valid explicit choice, so we
      # check whether the flag appeared in the original args)
      local mode_was_explicit=false
      for a in "${original_args[@]}"; do
        [[ "$a" == "--starship-mode" ]] && mode_was_explicit=true && break
      done
      if ! $mode_was_explicit; then
        warn "HyDE detected and starship selected in non-interactive mode."
        warn "Defaulting STARSHIP_MODE='dotfiles' (HYDE_ZSH_PROMPT=0 will be written)."
        warn "Use --starship-mode dotfiles|hyde|env to suppress this warning."
      fi
    fi
  fi

  if $UNINSTALL; then
    step "Uninstall (unstowing all packages)"
    unstow_all

    if $HYDE_DETECTED; then
      cleanup_hyde_patches
    fi

    ok "Unstow complete"
    exit 0
  fi

  # No meaningful arguments (ignoring --dry-run) → default to interactive
  local -a non_dry=()
  for a in "${original_args[@]}"; do
    [[ "$a" != "--dry-run" ]] && non_dry+=("$a")
  done
  if (( ${#non_dry[@]} == 0 )); then
    INTERACTIVE=true
  fi

  if $INTERACTIVE; then
    interactive_mode
  else
    # Explicit flags (--stow, --gitconfig, etc.) already queued tasks.
    # Fall back to default_base only when nothing was queued.
    if (( ${#TASKS[@]} == 0 )); then
      register_task "default_base"
    fi
  fi

  dry_run_summary
  execute_tasks

  printf '\n'
  ok "Done."
}

# Skip main() if --source-only is passed (used by bootstrap.sh)
# This allows bootstrap.sh to source install.sh to get detect_os() etc.
if [[ "${1:-}" != "--source-only" ]]; then
  main "$@"
fi
