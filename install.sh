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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=""
DRY_RUN=false
UNINSTALL=false
INTERACTIVE=false

TASKS=()
STOW_SELECTED=()
BREW_SELECTED=()
ARCH_SELECTED=()

# HyDE — populated by detect_hyde()
HYDE_DETECTED=false
HYDE_SHELL_BIN=""   # full path to hyde-shell binary
HYDE_CTL_BIN=""     # full path to hydectl binary

# Starship — resolved by prompt_starship_mode()
STARSHIP_MODE="dotfiles"   # dotfiles | hyde | env

# Backup timestamp — same across the whole run so all backups share a folder
BKP_TS="$(date +%Y%m%d_%H%M%S)"

###############################################################################
# Package lists
###############################################################################

BASE_STOW_PKGS=(bat eza ghostty lazygit local nvim starship tmux zsh)
MACOS_STOW_PKGS=(macos)
ARCH_STOW_PKGS=(arch-linux)

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

log()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
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

detect_os() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      ;;
    Linux)
      if grep -qi "arch" /etc/os-release 2>/dev/null; then
        OS="arch"
      else
        err "Unsupported Linux distro (only Arch is supported)"
        exit 1
      fi
      ;;
    *)
      err "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
  log "Detected OS: $OS"
}

###############################################################################
# HyDE detection
###############################################################################

detect_hyde() {
  # Locate hyde-shell — check PATH first, then well-known fallbacks
  local -a candidates
  mapfile -t candidates < <(
    command -v hyde-shell 2>/dev/null || true
    printf '%s\n' \
      "$HOME/.local/bin/hyde-shell" \
      "/usr/local/bin/hyde-shell"
  )

  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { HYDE_SHELL_BIN="$c"; break; }
  done

  # Locate hydectl
  local -a ctl_candidates
  mapfile -t ctl_candidates < <(
    command -v hydectl 2>/dev/null || true
    printf '%s\n' \
      "$HOME/.local/bin/hydectl" \
      "/usr/local/bin/hydectl"
  )

  for c in "${ctl_candidates[@]}"; do
    [[ -x "$c" ]] && { HYDE_CTL_BIN="$c"; break; }
  done

  # HyDE is present if the binary OR config directory exists
  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"
  local hyde_zsh_dir="$zdotdir/conf.d/hyde"

  if [[ -d "$hyde_zsh_dir" ]]; then
    HYDE_DETECTED=true
  elif [[ -n "$HYDE_SHELL_BIN" && -d "$HOME/.config/hyde" ]]; then
    # Fallback: binary + main config dir exist
    HYDE_DETECTED=true
  fi

  if $HYDE_DETECTED; then
    ok "HyDE install detected"
    if [[ -n "$HYDE_SHELL_BIN" ]]; then log "  hyde-shell → $HYDE_SHELL_BIN"; fi
    if [[ -n "$HYDE_CTL_BIN"   ]]; then log "  hydectl    → $HYDE_CTL_BIN";   fi
    if [[ -z "$HYDE_SHELL_BIN" ]]; then warn "hyde-shell not found in PATH — CLI features may be limited"; fi
  else
    log "HyDE not detected — plain dotfiles mode"
  fi
}

###############################################################################
# Backup helpers
###############################################################################

# backup_path PATH
#   Copies PATH → PATH.bak.<timestamp> unless PATH is already a stow symlink
#   pointing back into our dotfiles tree.
# Note: backup_hyde_zsh lives in scripts/hyde-patches.sh
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

  run stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
}

stow_packages() {
  local -a pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    stow_pkg "$pkg"
  done
}

unstow_all() {
  local -a all=(
    "${BASE_STOW_PKGS[@]}"
    "${MACOS_STOW_PKGS[@]}"
    "${ARCH_STOW_PKGS[@]}"
  )
  for pkg in "${all[@]}"; do
    # Silently ignore packages that were never stowed
    run stow -D --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>/dev/null || true
  done
}

###############################################################################
# Helpers (used by hyde-patches.sh and install.sh)
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

  local git_name git_email
  read -rp "  git user.name:  " git_name
  read -rp "  git user.email: " git_email
  git config --file "$dest" user.name  "$git_name"
  git config --file "$dest" user.email "$git_email"
  ok "gitconfig written"
}

###############################################################################
# Post-install
###############################################################################

post_install_task() {
  step "Post-install"

  # TPM
  if command -v tmux &>/dev/null; then
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
      log "Installing TPM"
      run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
      log "TPM already installed"
    fi
  fi

  # Ghostty: create arch-config overrides for Arch Linux
  local ghostty_config_dir="$HOME/.config/ghostty"
  local arch_config="$ghostty_config_dir/arch-config"
  if [[ -d "$ghostty_config_dir" ]]; then
    if $HYDE_DETECTED; then
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
      # For macOS, create an empty file if it doesn't exist
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
  else
    log "Ghostty config directory not found — skipping arch-config"
  fi

  # HyDE-specific post-install steps (in scripts/hyde-patches.sh)
  $HYDE_DETECTED && hyde_post_install
}

###############################################################################
# Task queue
###############################################################################

register_task() { TASKS+=("$1"); }

execute_tasks() {
  for task in "${TASKS[@]:-}"; do
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

  stow_packages "${STOW_SELECTED[@]}"

  # Apply starship mode only if starship was selected
  local starship_selected=false
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" == "starship" ]] && starship_selected=true && break
  done

  if $starship_selected; then
    apply_starship_mode
  fi

  # Patch HyDE's user.zsh and plugin.zsh (idempotent, in scripts/hyde-patches.sh)
  if $HYDE_DETECTED; then
    patch_user_zsh
    patch_plugin_zsh
    ensure_hyde_completions
  fi
}

brew_selected() {
  step "Homebrew"
  for f in "${BREW_SELECTED[@]:-}"; do
    brew_install "$f"
  done
}

arch_selected() {
  step "Arch packages"
  for f in "${ARCH_SELECTED[@]:-}"; do
    arch_install "$f"
  done
}

###############################################################################
# Dry-run summary
###############################################################################

dry_run_summary() {
  ! $DRY_RUN && return

  step "Dry Run Summary"

  printf "  OS: %s\n" "$OS"
  printf "  HyDE detected: %s\n" "$HYDE_DETECTED"

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
    for pkg in "${STOW_SELECTED[@]}"; do
      printf "    - %s\n" "$pkg"
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
# Interactive helpers
###############################################################################

# interactive_select ITEM...
#   Prints selected items to stdout, one per line.
#   Always exits 0 — empty output means "nothing selected / skip".
interactive_select() {
  if command -v fzf &>/dev/null; then
    # fzf exits 130 on Ctrl-C / Esc — treat as empty (not error)
    printf "%s\n" "$@" | fzf --multi --prompt="  select> " 2>/dev/null || true
    return 0
  fi

  # Fallback: numbered menu
  local -a items=("$@")
  printf '\n'
  local i=1
  for item in "${items[@]}"; do
    printf "    %2d) %s\n" "$i" "$item"
    (( i++, 1 ))
  done
  printf "     0) Skip\n\n"

  local input
  read -rp "  Space-separated numbers (0 to skip): " input

  for n in $input; do
    [[ "$n" == "0" ]] && return 0
    local idx=$(( n - 1 ))
    [[ -n "${items[$idx]:-}" ]] && printf '%s\n' "${items[$idx]}"
  done
}

###############################################################################
# Interactive mode
###############################################################################

interactive_mode() {
  step "Interactive mode"

  # In dry-run we skip prompts and simulate a full run
  if $DRY_RUN; then
    warn "Dry-run: registering all tasks (no prompts)"
    STOW_SELECTED=("${BASE_STOW_PKGS[@]}")
    [[ "$OS" == "macos" ]] && STOW_SELECTED+=("${MACOS_STOW_PKGS[@]}")
    [[ "$OS" == "arch"  ]] && STOW_SELECTED+=("${ARCH_STOW_PKGS[@]}")
    register_task "stow_selected"
    if [[ "$OS" == "macos" ]]; then
      BREW_SELECTED=("${BREW_FILES[@]}")
      register_task "brew_selected"
    elif [[ "$OS" == "arch" ]]; then
      ARCH_SELECTED=("${ARCH_PKG_FILES[@]}")
      register_task "arch_selected"
    fi
    STARSHIP_MODE="dotfiles"
    register_task "install_gitconfig_task"
    register_task "post_install_task"
    return
  fi

  # ── Stow packages ─────────────────────────────────────────────────────────
  local -a all_stow=("${BASE_STOW_PKGS[@]}")
  [[ "$OS" == "macos" ]] && all_stow+=("${MACOS_STOW_PKGS[@]}")
  [[ "$OS" == "arch"  ]] && all_stow+=("${ARCH_STOW_PKGS[@]}")

  printf '\n'
  log "Select packages to stow (Tab/Space = toggle, Enter = confirm, Esc = skip):"
  local sel
  sel="$(interactive_select "${all_stow[@]}")"

  if [[ -n "$sel" ]]; then
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] && STOW_SELECTED+=("$pkg")
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
  fi

  # ── OS-specific packages ───────────────────────────────────────────────────
  if [[ "$OS" == "macos" ]]; then
    printf '\n'
    log "Select Brewfiles to install:"
    local bsel
    bsel="$(interactive_select "${BREW_FILES[@]}")"
    if [[ -n "$bsel" ]]; then
      while IFS= read -r f; do
        [[ -n "$f" ]] && BREW_SELECTED+=("$f")
      done <<< "$bsel"
      register_task "brew_selected"
    else
      log "Skipping Homebrew"
    fi
  fi

  if [[ "$OS" == "arch" ]]; then
    printf '\n'
    log "Select Arch package lists to install:"
    local asel
    asel="$(interactive_select "${ARCH_PKG_FILES[@]}")"
    if [[ -n "$asel" ]]; then
      while IFS= read -r f; do
        [[ -n "$f" ]] && ARCH_SELECTED+=("$f")
      done <<< "$asel"
      register_task "arch_selected"
    else
      log "Skipping Arch packages"
    fi
  fi

  # ── Optional tasks ─────────────────────────────────────────────────────────
  printf '\n'
  local ans
  read -rp "  Install gitconfig? (y/N): " ans
  [[ "${ans:-n}" =~ ^[Yy]$ ]] && register_task "install_gitconfig_task"

  read -rp "  Run post-install tasks (TPM, HyDE reload)? (y/N): " ans
  [[ "${ans:-n}" =~ ^[Yy]$ ]] && register_task "post_install_task"

  # HyDE config.toml seed (arch + HyDE only, automatic — no prompt needed)
  if [[ "$OS" == "arch" ]] && $HYDE_DETECTED; then
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
  [[ "$OS" == "arch"  ]] && STOW_SELECTED+=("${ARCH_STOW_PKGS[@]}")

  if $HYDE_DETECTED; then
    warn "HyDE detected in non-interactive mode."
    warn "Defaulting starship mode to 'dotfiles' (HYDE_ZSH_PROMPT=0 will be written)."
    warn "Run interactively to choose a different mode: ./install.sh"
  fi

  stow_selected

  if [[ "$OS" == "arch" ]] && $HYDE_DETECTED; then
    register_task "hyde_seed_config"
  fi
}

###############################################################################
# Main
###############################################################################

main() {
  local -a original_args=("$@")

  detect_os
  detect_hyde

  # Source HyDE-specific patches when HyDE is present
  if $HYDE_DETECTED; then
    local patches="$DOTFILES_DIR/scripts/hyde-patches.sh"
    if [[ -f "$patches" ]]; then
      # shellcheck source=scripts/hyde-patches.sh
      source "$patches"
    else
      warn "scripts/hyde-patches.sh not found — HyDE patches unavailable"
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

main "$@"
