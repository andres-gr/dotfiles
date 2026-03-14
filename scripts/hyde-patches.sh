#!/usr/bin/env bash
# scripts/hyde-patches.sh — HyDE-specific install patches
# Sourced by install.sh when HYDE_DETECTED=true.
# Inherits all globals and helpers from install.sh.

###############################################################################
# backup_hyde_zsh
###############################################################################

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
# hyde_seed_config
###############################################################################

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
# prompt_starship_mode
###############################################################################

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

###############################################################################
# apply_starship_mode
###############################################################################

apply_starship_mode() {
  case "$STARSHIP_MODE" in
    dotfiles)
      log "Starship mode: dotfiles — HYDE_ZSH_PROMPT=0 via neo-hyde.zsh"
      ;;
    hyde)
      _remove_from_stow "starship"
      if ! $DRY_RUN; then
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
      local user_zsh="${ZDOTDIR:-$HOME/.config/zsh}/user.zsh"
      local custom_path
      read -rp "  Path to starship.toml [$HOME/.config/starship.toml]: " custom_path
      custom_path="${custom_path:-$HOME/.config/starship.toml}"
      log "Starship/env: STARSHIP_CONFIG=$custom_path"
      _append_if_absent "$user_zsh" \
        "# neo-dots: custom STARSHIP_CONFIG for env mode" \
        "export STARSHIP_CONFIG=\"$custom_path\""
      ;;
  esac
}

###############################################################################
# patch_user_zsh
#   Writes user.zsh with a single source line pointing to neo-hyde.zsh.
#   Idempotent — skips if marker already present.
###############################################################################

patch_user_zsh() {
  ! $HYDE_DETECTED && return
  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"
  local user_zsh="$zdotdir/user.zsh"
  local marker="# neo-dots managed — do not edit this line"
  if $DRY_RUN; then
    log "[dry-run] would write user.zsh → $user_zsh"
    return
  fi
  if grep -qF "$marker" "$user_zsh" 2>/dev/null; then
    log "neo-hyde.zsh source line already present in user.zsh — skipping"
    return
  fi
  log "Writing user.zsh → $user_zsh"
  mkdir -p "$(dirname "$user_zsh")"
  printf '%s\n' \
    "#  HyDE user configuration" \
    "# HyDE sources this file inside terminal.zsh before _load_prompt." \
    "# neo-dots injects the line below — do not remove it." \
    "# Add per-machine overrides AFTER the source line." \
    "" \
    "# neo-dots managed — do not edit this line" \
    '[[ -f "$ZDOTDIR/neo-hyde.zsh" ]] && source "$ZDOTDIR/neo-hyde.zsh"' \
    > "$user_zsh"
  ok "user.zsh written"
}

###############################################################################
# patch_plugin_zsh
#   Replaces `return 1` in HyDE's plugin.zsh to bypass OMZ. Idempotent.
###############################################################################

patch_plugin_zsh() {
  ! $HYDE_DETECTED && return
  local plugin_zsh="${ZDOTDIR:-$HOME/.config/zsh}/plugin.zsh"
  local marker="# neo-dots: delegates plugin loading to our plugins.zsh"
  if $DRY_RUN; then
    log "[dry-run] would patch plugin.zsh → bypass OMZ"
    return
  fi
  if grep -qF "$marker" "$plugin_zsh" 2>/dev/null; then
    log "plugin.zsh already patched — skipping"
    return
  fi
  if [[ ! -f "$plugin_zsh" ]]; then
    warn "plugin.zsh not found at $plugin_zsh — skipping"
    return
  fi
  log "Patching plugin.zsh → bypass OMZ"
  sed -i "s|^return 1.*|${marker}\n[[ -z \"\${_NEO_PLUGINS_LOADED:-}\" ]] \&\& source \"\$ZDOTDIR/plugins.zsh\"\nreturn 0|" \
    "$plugin_zsh"
  ok "plugin.zsh patched"
}

###############################################################################
# ensure_hyde_completions
###############################################################################

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
# cleanup_hyde_patches
#   Removes neo-dots injections from user.zsh on uninstall.
###############################################################################

cleanup_hyde_patches() {
  ! $HYDE_DETECTED && return
  local zdotdir="${ZDOTDIR:-$HOME/.config/zsh}"
  local user_zsh="$zdotdir/user.zsh"
  [[ -f "$user_zsh" ]] || return
  log "Cleaning up neo-dots patches from user.zsh"
  if $DRY_RUN; then
    log "[dry-run] would remove neo-dots managed blocks from user.zsh"
    return
  fi
  awk '
    /# neo-dots managed/               { skip=2 }
    /# Managed by neo-dots install/    { skip=2 }
    /# neo-dots: HyDE alias overrides/ { skip=99 }
    /# Check compinit security/        { skip=2 }
    skip > 0 { skip--; next }
    { print }
  ' "$user_zsh" > "${user_zsh}.tmp" && mv "${user_zsh}.tmp" "$user_zsh"
  ok "Removed neo-dots managed blocks from user.zsh"
}

###############################################################################
# hyde_post_install
#   HyDE-specific post-install: Hyprland reload, Dracula Pro GTK theme,
#   SDDM configuration, system.update.sh patch.
#   Called from post_install_task in install.sh when HYDE_DETECTED=true.
###############################################################################

hyde_post_install() {
  # Hyprland reload (only inside active session)
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    log "Hyprland session active — reloading config"
    run hyprctl reload 2>/dev/null || warn "hyprctl reload failed (non-fatal)"
    command -v pkill &>/dev/null && run pkill -SIGUSR2 waybar 2>/dev/null || true
  fi

  # HyDE theme reload
  if [[ -n "$HYDE_SHELL_BIN" ]]; then
    log "Running: hyde-shell reload"
    run "$HYDE_SHELL_BIN" reload 2>/dev/null || warn "hyde-shell reload failed (non-fatal)"
  fi

  # Remind about hyprlock preset if arch-linux was stowed
  local arch_stowed=false
  for pkg in "${STOW_SELECTED[@]:-}"; do
    [[ "$pkg" == "arch-linux" ]] && arch_stowed=true && break
  done
  if $arch_stowed; then
    log "Hyprlock preset 'neo' stowed → ~/.config/hypr/hyprlock/neo.conf"
    log "  theme.conf already points to it — active on next lock."
    log "  To switch preset: edit ~/.config/hypr/hyprlock/theme.conf"
  fi

  # Build Dracula Pro GTK theme
  step "Building Dracula Pro GTK theme"
  local gtk_src_dir="$HOME/.local/share/neo-dots/dracula-gtk-src"
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
    local -a gtk_subs=(
      "rgba(189, 147, 249, 0.5)|rgba(149, 128, 255, 0.5)"
      "rgba(25, 26, 34, 0.9)|rgba(27, 26, 35, 0.9)"
      "#282a36|#22212c" "#282A36|#22212C"
      "#1e1f29|#1b1a23" "#1E1F29|#1B1A23"
      "#191a22|#1b1a23" "#191A22|#1B1A23"
      "#44475a|#454158" "#44475A|#454158"
      "#6272a4|#7970a9" "#6272A4|#7970A9"
      "#7b7bbd|#7970a9" "#7B7BBD|#7970A9"
      "#bd93f9|#9580ff" "#BD93F9|#9580FF"
      "#13b1d5|#9580ff" "#13B1D5|#9580FF"
      "#72bfd0|#80ffea" "#72BFD0|#80FFEA"
      "#ff79c6|#ff80bf" "#FF79C6|#FF80BF"
      "#ff5555|#ff9580" "#FF5555|#FF9580"
      "#ffb86c|#ffca80" "#FFB86C|#FFCA80"
      "#f1fa8c|#ffff80" "#F1FA8C|#FFFF80"
      "#50fa7b|#8aff80" "#50FA7B|#8AFF80"
      "#50fa7a|#8aff80" "#50FA7A|#8AFF80"
      "#8be9fd|#80ffea" "#8BE9FD|#80FFEA"
    )
    local perl_script=""
    for pair in "${gtk_subs[@]}"; do
      local from="${pair%%|*}" to="${pair##*|}"
      perl_script+="s|\Q${from}\E|${to}|g;"
    done
    log "Applying Dracula Pro color substitutions"
    find "$gtk_src_dir" -type f \( -name '*.css' -o -name '*.scss' \) \
      -not -path '*/.git/*' \
      -exec perl -p -i -e "$perl_script" {} \;
    log "Installing to $gtk_dest"
    mkdir -p "$gtk_dest"
    for gtk_dir in gtk-3.0 gtk-4.0 gtk-3.20; do
      [[ -d "$gtk_src_dir/$gtk_dir" ]] && cp -r "$gtk_src_dir/$gtk_dir" "$gtk_dest/"
    done
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
    if [[ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]]; then
      run gsettings set org.gnome.desktop.interface gtk-theme 'Dracula Pro' 2>/dev/null || true
      log "Applied gtk-theme: Dracula Pro"
    fi
  fi

  # Configure SDDM Candy theme
  local sddm_theme_dir="/usr/share/sddm/themes/Candy"
  if [[ -d "$sddm_theme_dir" ]]; then
    step "Configuring SDDM Candy theme for dual 1440p setup"
    local theme_conf="${sddm_theme_dir}/theme.conf"
    if [[ -f "$theme_conf" ]]; then
      run sudo sed -i 's|^ScreenWidth=.*|ScreenWidth="2560"|'            "$theme_conf"
      run sudo sed -i 's|^ScreenHeight=.*|ScreenHeight="1440"|'          "$theme_conf"
      run sudo sed -i 's|^FormPosition=.*|FormPosition="right"|'         "$theme_conf"
      run sudo sed -i 's|^AccentColor=.*|AccentColor="#9580FF"|'         "$theme_conf"
      run sudo sed -i 's|^BackgroundColor=.*|BackgroundColor="#22212C"|' "$theme_conf"
      run sudo sed -i 's|^HeaderText=.*|HeaderText=""|'                  "$theme_conf"
      run sudo sed -i 's|^Font=.*|Font="JetBrains Mono"|'               "$theme_conf"
      log "SDDM theme.conf patched"
    else
      warn "SDDM theme.conf not found at ${theme_conf} — skipping"
    fi
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
    _install_sddm_edid_service
  else
    log "SDDM Candy theme not installed yet — skipping (re-run after HyDE install)"
  fi

  # Patch system.update.sh: replace hardcoded kitty with xdg-terminal-exec
  local sysupdate="$HOME/.local/lib/hyde/system.update.sh"
  if [[ -f "$sysupdate" ]]; then
    if grep -q 'kitty --title systemupdate' "$sysupdate"; then
      sed -i 's|kitty --title systemupdate|xdg-terminal-exec --title=systemupdate|g' "$sysupdate"
      log "Patched system.update.sh: kitty → xdg-terminal-exec"
    else
      log "system.update.sh: kitty reference not found — already patched or upstream changed"
    fi
  fi
}

# Helper: install the SDDM EDID output detection systemd service
_install_sddm_edid_service() {
  local detect_script="/usr/local/bin/sddm-detect-output"
  local detect_unit="/etc/systemd/system/sddm-detect-output.service"
  log "Installing SDDM output-detection service"
  sudo tee "$detect_script" > /dev/null <<'DETECT_SCRIPT'
#!/usr/bin/env python3
# sddm-detect-output: run by systemd before SDDM on every boot.
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
            raw = os.path.basename(connector_dir)
            return re.sub(r"^card\d+-", "", raw)
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
}
