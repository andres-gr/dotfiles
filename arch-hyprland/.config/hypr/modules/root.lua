-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env('_JAVA_AWT_WM_NONREPARENTING', '1')
hl.env('CLUTTER_BACKEND', 'wayland')
hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'auto')
hl.env('JAVA_TOOL_OPTIONS', '-Dawt.useSystemAAFontSettings=on')
hl.env('MOZ_DBUS_REMOTE', '1')
hl.env('MOZ_ENABLE_WAYLAND', '1')
hl.env('NIXOS_OZONE_WL', 'true')
hl.env('QT_AUTO_SCREEN_SCALE_FACTOR', '1')
hl.env('QT_QPA_PLATFORM', 'wayland')
hl.env('QT_QPA_PLATFORMTHEME', 'qt6ct')
hl.env('QT_QPA_PLATFORMTHEME_QT6', 'qt6ct')
hl.env('QT_WAYLAND_DISABLE_WINDOWDECORATION', '1')
hl.env('SDL_VIDEODRIVER', 'wayland')
hl.env('TERMINAL', 'ghostty')
hl.env('XDG_CURRENT_DESKTOP', 'Hyprland')
hl.env('XDG_MENU_PREFIX', 'arch-')
hl.env('XDG_SESSION_DESKTOP', 'Hyprland')
hl.env('XDG_SESSION_TYPE', 'wayland')
hl.env('YDOTOOL_SOCKET', '/tmp/ydotool.sock')


-------------------------------
---- AUTOSTART COMMANDS -------
-------------------------------

hl.on('hyprland.start', function()
  -- 1. Hard-kill any stray/SDDM-inherited portals to flush their cache
  hl.exec_cmd 'systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-gnome xdg-desktop-portal-kde'

  -- 2. Inject clean attributes so D-Bus evaluates only your Hyprland configuration profile
  hl.exec_cmd 'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland'
  hl.exec_cmd 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland'

  -- 3. Explicitly restart the core portal wrapper with the fresh environment variables
  hl.exec_cmd 'systemctl --user start xdg-desktop-portal'

  hl.exec_cmd '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'
  hl.exec_cmd 'hyprpm reload'

  hl.exec_cmd 'wayland-pipewire-idle-inhibit'

  hl.dispatch(hl.dsp.focus { workspace = 1 })
  hl.dispatch(hl.dsp.cursor.move_to_corner { corner = 1 })
end)
