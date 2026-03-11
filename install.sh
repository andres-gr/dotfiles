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
    [[ -n "$HYDE_SHELL_BIN" ]] && log "  hyde-shell → $HYDE_SHELL_BIN"
    [[ -n "$HYDE_CTL_BIN"   ]] && log "  hydectl    → $HYDE_CTL_BIN"
    [[ -z "$HYDE_SHELL_BIN" ]] && warn "hyde-shell not found in PATH — CLI features may be limited"
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
}

# backup_hyde_zsh
#   Backs up every HyDE-owned zsh path into a single datestamped archive dir
#   so they are easy to inspect and restore.
backup_hyde_zsh() {
  local bkp_root="$HOME/.local/share/neo-dots/hyde-bkp/${BKP_TS}"
  log "HyDE zsh backup dir: $bkp_root"

  for rel in "${HYDE_OWNED_ZSH[@]}"; do
    local src="$HOME/$rel"
    [[ -e "$src" || -L "$src" ]] || continue
    local dest_dir="$bkp_root/$(dirname "$rel")"
    run mkdir -p "$dest_dir"
    run cp -a "$src" "$dest_dir/"
    ok "  saved: $src"
  done
}

###############################################################################
# HyDE config.toml seeding
###############################################################################

# hyde_seed_config
#   Copies our config.toml into ~/.config/hyde/ ONLY when the file does not
#   already exist there (mirrors HyDE's own "P = Populate/Preserved" flag).
#   The user's live config.toml is never clobbered by subsequent installs.
hyde_seed_config() {
  ! $HYDE_DETECTED && return
  [[ "$OS" != "arch" ]] && return

  step "HyDE config.toml"

  if [[ ! -f "$HYDE_CONFIG_TOML_SRC" ]]; then
    warn "config.toml source not found: $HYDE_CONFIG_TOML_SRC — skipping"
    return
  fi

  if [[ -f "$HYDE_CONFIG_TOML_DEST" ]]; then
    log "config.toml already exists — skipping seed (edit directly to change)"
    log "  $HYDE_CONFIG_TOML_DEST"
    return
  fi

  log "Seeding config.toml → $HYDE_CONFIG_TOML_DEST"
  run mkdir -p "$(dirname "$HYDE_CONFIG_TOML_DEST")"
  run cp "$HYDE_CONFIG_TOML_SRC" "$HYDE_CONFIG_TOML_DEST"
  ok "config.toml seeded"
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

    # stow prints: "  * existing target is neither a link nor a directory: .some/path"
    while IFS= read -r line; do
      [[ "$line" == *"existing target is"* ]] || continue
      local rel="${line#*: }"
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
# Starship prompt mode
###############################################################################

# prompt_starship_mode
#   Presented only when HyDE is detected. Explains the three modes and stores
#   the choice in $STARSHIP_MODE.
#
#   Why this matters:
#     HyDE's conf.d/hyde/terminal.zsh sources conf.d/00-hyde.zsh which in turn
#     calls _load_prompt → conf.d/hyde/prompt.zsh → starship init zsh.
#     Our conf.d/60-tools.zsh ALSO calls starship init zsh.
#     If both fire in the same session the prompt double-initialises.
#
#     The fix is to let only ONE of them own the starship init:
#       dotfiles → set HYDE_ZSH_PROMPT=0 in user.zsh; 60-tools.zsh wins
#       hyde     → skip our starship/ pkg; HyDE wins
#       env      → set HYDE_ZSH_PROMPT=0 + custom STARSHIP_CONFIG; 60-tools wins
prompt_starship_mode() {
  ! $HYDE_DETECTED && { STARSHIP_MODE="dotfiles"; return; }

  cat <<'EOF'

  ┌─────────────────────────────────────────────────────────────────┐
  │  HyDE is installed. Choose how Starship should be configured:   │
  ├─────────────────────────────────────────────────────────────────┤
  │  1) dotfiles  Our starship.toml; we own "starship init zsh"     │
  │               (stows starship/ pkg; disables HYDE_ZSH_PROMPT)   │
  │                                                                 │
  │  2) hyde      HyDE manages starship entirely — no stow          │
  │               (STARSHIP_CONFIG stays at HyDE's starship.toml)   │
  │                                                                 │
  │  3) env       Custom STARSHIP_CONFIG path; we own the init      │
  │               (no stow of starship/; disables HYDE_ZSH_PROMPT)  │
  └─────────────────────────────────────────────────────────────────┘
EOF

  local choice
  while true; do
    read -rp "  Choice [1/2/3] (default 1): " choice
    choice="${choice:-1}"
    case "$choice" in
      1) STARSHIP_MODE="dotfiles"; break ;;
      2) STARSHIP_MODE="hyde";     break ;;
      3) STARSHIP_MODE="env";      break ;;
      *) warn "Enter 1, 2, or 3" ;;
    esac
  done
  log "Starship mode: $STARSHIP_MODE"
}

# apply_starship_mode
#   Called after stow has run. Writes into $ZDOTDIR/user.zsh (HyDE's official
#   user-customisation file, sourced inside terminal.zsh before _load_prompt).
#   This is the correct place to override HYDE_ZSH_PROMPT because terminal.zsh
#   sets it to "1" first, sources user.zsh, then calls _load_prompt — so
#   unsetting it in user.zsh takes effect before the prompt initialises.
apply_starship_mode() {
  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"
  local user_zsh="$zdotdir/user.zsh"

  case "$STARSHIP_MODE" in

    dotfiles)
      # Disable HyDE's starship init; our 60-tools.zsh will fire instead.
      # Our starship/ stow package writes ~/.config/starship.toml which is a
      # different path from HyDE's ~/.config/starship/starship.toml — no clash.
      if $HYDE_DETECTED; then
        log "Starship/dotfiles: writing HYDE_ZSH_PROMPT=0 → $user_zsh"
        _append_if_absent "$user_zsh" \
          "# Managed by neo-dots install — dotfiles owns starship init" \
          "HYDE_ZSH_PROMPT=0"
      fi
      ;;

    hyde)
      # Remove our starship/ pkg from the stow list (already ran, but we
      # remove from STOW_SELECTED so dry-run output is accurate too).
      # If it was stowed, unstow it so HyDE's starship.toml takes precedence.
      _remove_from_stow "starship"
      if ! $DRY_RUN; then
        # Check whether any of starship's files are currently stowed by us
        local any_stowed=false
        while IFS= read -r -d '' link; do
          local target
          target="$(readlink -f "$link" 2>/dev/null || true)"
          [[ "$target" == "$DOTFILES_DIR/starship/"* ]] && any_stowed=true && break
        done < <(find "$HOME" -maxdepth 4 -type l -print0 2>/dev/null)
        $any_stowed && run stow -D --no-folding -d "$DOTFILES_DIR" -t "$HOME" starship 2>/dev/null || true
      fi
      log "Starship/hyde: HyDE manages starship; starship/ pkg not stowed"
      ;;

    env)
      _remove_from_stow "starship"
      run stow -D --no-folding -d "$DOTFILES_DIR" -t "$HOME" starship 2>/dev/null || true

      local custom_path
      read -rp "  Path to starship.toml [$HOME/.config/starship.toml]: " custom_path
      custom_path="${custom_path:-$HOME/.config/starship.toml}"

      log "Starship/env: STARSHIP_CONFIG=$custom_path"
      _append_if_absent "$user_zsh" \
        "# Managed by neo-dots install — custom STARSHIP_CONFIG" \
        "export STARSHIP_CONFIG=\"$custom_path\""
      _append_if_absent "$user_zsh" \
        "# Managed by neo-dots install — env mode disables HyDE prompt init" \
        "HYDE_ZSH_PROMPT=0"
      ;;
  esac
}

# _remove_from_stow PKG
#   Removes PKG from STOW_SELECTED in-place.
_remove_from_stow() {
  local remove="$1"
  local -a filtered=()
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" != "$remove" ]] && filtered+=("$pkg")
  done
  STOW_SELECTED=("${filtered[@]}")   # safe — filtered is declared, just empty
}

# _append_if_absent FILE COMMENT LINE
#   Writes COMMENT + LINE to FILE only when LINE is not already present.
#   Creates the file (and parent dirs) if needed.
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
# HyDE completion guard
###############################################################################

# ensure_hyde_completions
#   After stow runs, verify that HyDE's completion files are still present.
#   stow --no-folding will never delete files it doesn't own, but we confirm
#   and attempt to regenerate if anything went missing.
ensure_hyde_completions() {
  ! $HYDE_DETECTED && return

  step "Verifying HyDE completion files"
  local comp_dir="${ZDOTDIR:-$HOME/.config/zsh}/completions"
  local ok_count=0

  for f in hyde-shell.zsh hydectl.zsh; do
    if [[ -f "$comp_dir/$f" ]]; then
      ok "  present: $comp_dir/$f"
      (( ok_count++, 1 ))
    else
      warn "  missing: $comp_dir/$f"
    fi
  done

  if (( ok_count < 2 )) && [[ -n "$HYDE_SHELL_BIN" ]]; then
    log "Attempting to regenerate via: hyde-shell --completions zsh"
    if ! $DRY_RUN; then
      mkdir -p "$comp_dir"
      "$HYDE_SHELL_BIN" --completions zsh > "$comp_dir/hyde-shell.zsh" 2>/dev/null \
        && ok "  regenerated hyde-shell.zsh" \
        || warn "  could not regenerate — run: hyde-shell --completions zsh"
    fi
  fi
}


###############################################################################
# Starship cleanup after uninstall
###############################################################################
cleanup_starship_overrides() {
  ! $HYDE_DETECTED && return

  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"
  local user_zsh="$zdotdir/user.zsh"

  [[ -f "$user_zsh" ]] || return

  log "Cleaning up starship overrides in user.zsh"

  if $DRY_RUN; then
    log "[dry-run] would remove neo-dots managed blocks from user.zsh"
    return
  fi

  # Remove lines containing our managed markers and the following line
  # We assume comment + config line structure
  awk '
    /# Managed by neo-dots install/ { skip=2 }
    skip > 0 { skip--; next }
    { print }
  ' "$user_zsh" > "${user_zsh}.tmp" && mv "${user_zsh}.tmp" "$user_zsh"

  ok "Removed neo-dots starship overrides"
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

  # HyDE-specific reloads
  if $HYDE_DETECTED; then
    # Only reload if we're inside an active Hyprland session
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
      log "Hyprland session active — reloading config"
      run hyprctl reload 2>/dev/null \
        || warn "hyprctl reload failed (non-fatal)"

      # Soft-reload waybar so theme changes apply without a full restart
      if command -v pkill &>/dev/null; then
        run pkill -SIGUSR2 waybar 2>/dev/null || true
      fi
    fi

    # Ask HyDE to re-apply its current theme (picks up any conf changes)
    if [[ -n "$HYDE_SHELL_BIN" ]]; then
      log "Running: hyde-shell reload"
      run "$HYDE_SHELL_BIN" reload 2>/dev/null \
        || warn "hyde-shell reload failed (non-fatal)"
    fi

    # Remind about hyprlock preset if we just stowed arch-linux
    if $HYDE_DETECTED; then
      local arch_stowed=false
      for pkg in "${STOW_SELECTED[@]:-}"; do
        [[ "$pkg" == "arch-linux" ]] && arch_stowed=true && break
      done
      if $arch_stowed; then
        log "Hyprlock preset 'neo' stowed → ~/.config/hypr/hyprlock/neo.conf"
        log "  theme.conf already points to it — active on next lock."
        log "  To switch preset: edit ~/.config/hypr/hyprlock/theme.conf"
      fi
    fi

    # Build Dracula Pro GTK theme by patching the standard Dracula GTK theme CSS.
    # Clones dracula/gtk to a staging area, applies perl literal-string substitution
    # of every standard Dracula color to its Dracula Pro equivalent, then copies
    # the result to ~/.themes/Dracula Pro/. The git working tree is reset on each
    # re-run so the substitutions are always applied cleanly from upstream.
    # Requires: git, perl (always present on Arch).
    step "Building Dracula Pro GTK theme"
    local gtk_src_dir="$HOME/.local/share/neo-dots/dracula-gtk-src"
    local gtk_stage
    gtk_stage="$(mktemp -d)"
    local gtk_dest="$HOME/.themes/Dracula Pro"

    if [[ ! -d "$gtk_src_dir/.git" ]]; then
      log "Cloning Dracula GTK theme source"
      run git clone --depth=1 https://github.com/dracula/gtk "$gtk_src_dir"
    else
      log "Dracula GTK source already present — resetting to upstream"
      run git -C "$gtk_src_dir" fetch --depth=1 origin
      run git -C "$gtk_src_dir" reset --hard origin/HEAD
    fi

    if ! $DRY_RUN; then
      # Color substitution map: standard Dracula → Dracula Pro
      # Uses perl \Q...\E for literal-string replacement — no regex escaping
      # issues with parens, dots, or spaces in rgba() values. Ordered so
      # longer/more-specific patterns (rgba, mixed-case) come before shorter
      # ones that could accidentally match a substring.
      local -a gtk_subs=(
        # rgba forms — must come before bare hex to avoid digit collisions
        "rgba(189, 147, 249, 0.5)|rgba(149, 128, 255, 0.5)"
        "rgba(25, 26, 34, 0.9)|rgba(27, 26, 35, 0.9)"
        # backgrounds
        "#282a36|#22212c"
        "#282A36|#22212C"
        "#1e1f29|#1b1a23"
        "#1E1F29|#1B1A23"
        "#191a22|#1b1a23"
        "#191A22|#1B1A23"
        # selection / current line
        "#44475a|#454158"
        "#44475A|#454158"
        # comment / slider
        "#6272a4|#7970a9"
        "#6272A4|#7970A9"
        "#7b7bbd|#7970a9"
        "#7B7BBD|#7970A9"
        # purple
        "#bd93f9|#9580ff"
        "#BD93F9|#9580FF"
        # blue (links/progress) → Pro purple (closest warm accent)
        "#13b1d5|#9580ff"
        "#13B1D5|#9580FF"
        # GTK cyan (#72BFD0) → Pro cyan
        "#72bfd0|#80ffea"
        "#72BFD0|#80FFEA"
        # pink
        "#ff79c6|#ff80bf"
        "#FF79C6|#FF80BF"
        # red
        "#ff5555|#ff9580"
        "#FF5555|#FF9580"
        # orange
        "#ffb86c|#ffca80"
        "#FFB86C|#FFCA80"
        # yellow
        "#f1fa8c|#ffff80"
        "#F1FA8C|#FFFF80"
        # green (both lime variants present in upstream source)
        "#50fa7b|#8aff80"
        "#50FA7B|#8AFF80"
        "#50fa7a|#8aff80"
        "#50FA7A|#8AFF80"
        # cyan (standard Dracula #8be9fd)
        "#8be9fd|#80ffea"
        "#8BE9FD|#80FFEA"
      )

      # Build perl substitution script — \Q...\E treats the pattern as a
      # literal string, so parens, dots, pipes etc. need no manual escaping.
      local perl_script=""
      for pair in "${gtk_subs[@]}"; do
        local from="${pair%%|*}" to="${pair##*|}"
        perl_script+="s|\Q${from}\E|${to}|g;"
      done

      log "Applying Dracula Pro color substitutions (perl literal-string)"
      # Patch all CSS and SCSS files in-place
      find "$gtk_src_dir" -type f \( -name '*.css' -o -name '*.scss' \) \
        -not -path '*/.git/*' \
        -exec perl -p -i -e "$perl_script" {} \;

      # Install: copy patched theme to ~/.themes/Dracula Pro
      log "Installing to $gtk_dest"
      mkdir -p "$gtk_dest"
      # Copy the GTK directories that apps actually use
      for gtk_dir in gtk-3.0 gtk-4.0 gtk-3.20; do
        [[ -d "$gtk_src_dir/$gtk_dir" ]] && \
          cp -r "$gtk_src_dir/$gtk_dir" "$gtk_dest/"
      done
      # index.theme is required for GTK to recognise the theme
      cat > "$gtk_dest/index.theme" <<'THEME_EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Dracula Pro
Comment=Dracula Pro GTK theme — patched from dracula/gtk
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Dracula Pro
MetacityTheme=Dracula Pro
IconTheme=Tela-circle-dracula
CursorTheme=Dracula-cursors
ButtonLayout=menu:minimize,maximize,close
THEME_EOF
      ok "Dracula Pro GTK theme installed → $gtk_dest"

      # Apply the theme immediately if in a live session
      if [[ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]]; then
        run gsettings set org.gnome.desktop.interface gtk-theme 'Dracula Pro' 2>/dev/null || true
        log "Applied gtk-theme: Dracula Pro"
      fi
    fi

    # Configure SDDM: patch theme.conf, fix Input.qml for 1440p, and set the
    # primary monitor output dynamically by matching the monitor EDID model string.
    # The EDID 0xFC descriptor block contains the monitor model name as plain ASCII,
    # allowing us to identify the correct connector without hardcoding (e.g.) DP-1.
    # This survives the monitor being moved to a different port.
    local sddm_theme_dir="/usr/share/sddm/themes/Candy"
    local sddm_conf="/etc/sddm.conf.d/the_hyde_project.conf"

    if [[ -d "$sddm_theme_dir" ]]; then
      step "Configuring SDDM Candy theme for dual 1440p setup"

      # --- 1. Patch theme.conf ---
      local theme_conf="${sddm_theme_dir}/theme.conf"
      if [[ -f "$theme_conf" ]]; then
        run sudo sed -i 's|^ScreenWidth=.*|ScreenWidth="2560"|'     "$theme_conf"
        run sudo sed -i 's|^ScreenHeight=.*|ScreenHeight="1440"|'   "$theme_conf"
        run sudo sed -i 's|^FormPosition=.*|FormPosition="right"|'  "$theme_conf"
        run sudo sed -i 's|^AccentColor=.*|AccentColor="#9580FF"|'         "$theme_conf"
        run sudo sed -i 's|^BackgroundColor=.*|BackgroundColor="#22212C"|' "$theme_conf"
        run sudo sed -i 's|^HeaderText=.*|HeaderText=""|'           "$theme_conf"
        run sudo sed -i 's|^Font=.*|Font="JetBrains Mono"|'         "$theme_conf"
        log "SDDM theme.conf patched"
      else
        warn "SDDM theme.conf not found at ${theme_conf} — skipping"
      fi

      # --- 2. Patch Input.qml: fix avatar icon width for 1440p ---
      # Stock Candy has: width: selectUser.height * 0.8
      # At 1440p this makes the avatar icon too small; drop the multiplier.
      local input_qml="${sddm_theme_dir}/Components/Input.qml"
      if [[ -f "$input_qml" ]]; then
        if grep -qF 'selectUser.height * 0.8' "$input_qml"; then
          run sudo sed -i 's/selectUser\.height \* 0\.8/selectUser.height/g' "$input_qml"
          log "SDDM Input.qml patched: avatar icon width fixed for 1440p"
        else
          log "SDDM Input.qml: already patched or upstream changed — skipping"
        fi
      else
        warn "SDDM Input.qml not found at ${input_qml} — skipping"
      fi

      # --- 3. Install boot-time EDID detection service ---
      # A systemd oneshot service runs before SDDM on every boot. It walks
      # /sys/class/drm to find the connector hosting the main monitor by its
      # EDID 0xFC model name, then rewrites OutputName in the_hyde_project.conf.
      # Moving the cable to a different DP port is handled automatically on the
      # next boot — no manual intervention required.
      local detect_script="/usr/local/bin/sddm-detect-output"
      local detect_unit="/etc/systemd/system/sddm-detect-output.service"

      log "Installing SDDM output-detection service"

      sudo tee "$detect_script" > /dev/null <<'DETECT_SCRIPT'
#!/usr/bin/env python3
# sddm-detect-output: run by systemd before SDDM on every boot.
# Finds the DRM connector carrying the target monitor (by EDID model name)
# and writes OutputName into /etc/sddm.conf.d/the_hyde_project.conf.
import glob, os, re, sys

TARGET_MODEL = "VG27AQ3A"
SDDM_CONF    = "/etc/sddm.conf.d/the_hyde_project.conf"

def edid_monitor_name(path):
    try:
        data = open(path, "rb").read()
        if len(data) < 128:
            return None
        for i in range(4):
            base = 54 + i * 18
            block = data[base:base+18]
            if block[0:3] == b"\x00\x00\x00" and block[3] == 0xFC:
                return block[5:18].decode("latin-1").rstrip().rstrip("\n")
    except Exception:
        pass
    return None

def find_connector():
    for edid_path in sorted(glob.glob("/sys/class/drm/card*-*/edid")):
        if not os.path.getsize(edid_path):
            continue
        name = edid_monitor_name(edid_path)
        if name and TARGET_MODEL in name:
            connector_dir = os.path.dirname(edid_path)
            raw = os.path.basename(connector_dir)   # e.g. card1-DP-2
            return re.sub(r"^card\d+-", "", raw)    # e.g. DP-2
    return None

def update_conf(connector):
    if not os.path.exists(SDDM_CONF):
        print(f"[sddm-detect-output] conf not found: {SDDM_CONF}", file=sys.stderr)
        sys.exit(1)
    text = open(SDDM_CONF).read()
    if "[Wayland]" not in text:
        text += f"\n[Wayland]\nEnableHiDPI=true\nOutputName={connector}\n"
    elif re.search(r"^OutputName=", text, re.MULTILINE):
        text = re.sub(r"^OutputName=.*", f"OutputName={connector}", text, flags=re.MULTILINE)
    else:
        text = re.sub(r"(\[Wayland\])", f"\\1\nOutputName={connector}", text)
    open(SDDM_CONF, "w").write(text)
    print(f"[sddm-detect-output] OutputName={connector} written to {SDDM_CONF}")

connector = find_connector()
if connector:
    update_conf(connector)
else:
    print(f"[sddm-detect-output] WARNING: {TARGET_MODEL} not found via EDID — OutputName unchanged",
          file=sys.stderr)
    sys.exit(1)
DETECT_SCRIPT

      run sudo chmod +x "$detect_script"

      sudo tee "$detect_unit" > /dev/null <<'DETECT_UNIT'
[Unit]
Description=Detect SDDM primary output from monitor EDID
After=systemd-udev-settle.service
Before=sddm.service
RequiresMountsFor=/etc/sddm.conf.d

[Service]
Type=oneshot
ExecStart=/usr/local/bin/sddm-detect-output
RemainAfterExit=no

[Install]
WantedBy=sddm.service
DETECT_UNIT

      run sudo systemctl daemon-reload
      run sudo systemctl enable sddm-detect-output.service
      ok "SDDM output-detection service installed and enabled"

    else
      log "SDDM Candy theme not installed yet — skipping (re-run after HyDE install)"
    fi

    # Patch system.update.sh: replace hardcoded 'kitty' with xdg-terminal-exec
    # HyDE upstream hardcodes kitty in system.update.sh (checked March 2026).
    # xdg-terminal-exec is already shipped by HyDE in ~/.local/lib/hyde/ and
    # respects ~/.config/xdg-terminals.list, making this terminal-agnostic.
    local sysupdate="$HOME/.local/lib/hyde/system.update.sh"
    if [[ -f "$sysupdate" ]]; then
      if grep -q 'kitty --title systemupdate' "$sysupdate"; then
        sed -i 's|kitty --title systemupdate|xdg-terminal-exec --title=systemupdate|g' "$sysupdate"
        log "Patched system.update.sh: kitty → xdg-terminal-exec"
      else
        log "system.update.sh: kitty reference not found — already patched or upstream changed"
      fi
    fi
  fi
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

  # Verify HyDE's completion files were not accidentally removed
  ensure_hyde_completions
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
  if (( ${#STOW_SELECTED[@]:-0} > 0 )); then
    printf "\n  Stow packages:\n"
    for pkg in "${STOW_SELECTED[@]}"; do
      printf "    - %s\n" "$pkg"
    done
  fi

  # Brew
  if (( ${#BREW_SELECTED[@]:-0} > 0 )); then
    printf "\n  Brew bundles:\n"
    for f in "${BREW_SELECTED[@]}"; do
      printf "    - %s\n" "$f"
    done
  fi

  # Arch
  if (( ${#ARCH_SELECTED[@]:-0} > 0 )); then
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
      cleanup_starship_overrides
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
