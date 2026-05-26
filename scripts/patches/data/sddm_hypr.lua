hl.env('XDG_CURRENT_DESKTOP', 'Hyprland')
hl.env('XDG_SESSION_DESKTOP', 'Hyprland')
hl.env('XDG_SESSION_TYPE', 'wayland')

hl.config {
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
}

hl.monitor {
  output = 'desc:{{main_monitor}}',
  mode = '2560x1440@120.0',
  position = '2560x0',
  scale = 1,
}

hl.monitor {
  output = 'desc:{{secondary_monitor}}',
  disabled = true,
}

hl.workspace_rule {
  workspace = 1,
  monitor = 'desc:{{main_monitor}}',
  default = true,
  persistent = true,
}

hl.on('hyprland.start', function()
  hl.exec_cmd 'sddm-greeter-qt6 --socket $WAYLAND_DISPLAY'
  hl.exec_cmd 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP'
  hl.exec_cmd 'hyprctl --batch \'dispatch workspace 1; dispatch movecursortocorner 1\''
end)
