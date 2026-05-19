-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env('_JAVA_AWT_WM_NONREPARENTING', '1')
hl.env('CLUTTER_BACKEND', 'wayland')
hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'auto')
hl.env('JAVA_TOOL_OPTIONS', '-Dawt.useSystemAAFontSettings=on')
hl.env('MOZ_DBUS_REMOTE', 'true')
hl.env('MOZ_ENABLE_WAYLAND', 'true')
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
  hl.exec_cmd 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP'
  hl.exec_cmd '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'
  hl.exec_cmd 'hyprpm reload'
  hl.exec_cmd "hyprctl --batch 'dispatch workspace 1; dispatch movecursortocorner 1'"
end)
