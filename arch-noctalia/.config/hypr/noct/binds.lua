-- Noctalia Hyprland binds
-- Overrides base binds for Noctalia shell integration

local mod = require 'utils.mod_key'

-- ── Unbind conflicting keys (override base binds) ──

hl.unbind 'ALT + SPACE'
hl.unbind 'ALT + CTRL + DELETE'
hl.unbind 'XF86AudioRaiseVolume'
hl.unbind 'XF86AudioLowerVolume'
hl.unbind 'XF86AudioMute'
hl.unbind 'XF86AudioMicMute'
hl.unbind 'XF86AudioPlay'
hl.unbind 'XF86AudioPause'
hl.unbind 'XF86AudioNext'
hl.unbind 'XF86AudioPrev'

-- ── Application Launchers ──

hl.bind('ALT + SPACE', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call launcher toggle', {
  description = 'Application Launcher',
})
hl.bind(mod .. '+ S', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call controlCenter toggle', {
  description = 'Control Center',
})
hl.bind(mod .. '+ SHIFT + S', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call launcher emoji', {
  description = 'Emoji Picker',
})
hl.bind(mod .. '+ V', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call launcher clipboard', {
  description = 'Clipboard Manager',
})
hl.bind(mod .. '+ SHIFT + BACKSPACE', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call sessionMenu toggle', {
  description = 'Power Menu: Toggle',
})
hl.bind(mod .. '+ N', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call notifications toggleHistory', {
  description = 'Notification Center',
})

-- ── Security ──

hl.bind(mod .. '+ ALT + CTRL + L', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call lockScreen lock', {
  description = 'Lock Screen',
})
hl.bind('ALT + CTRL + SHIFT + L', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call sessionMenu lockAndSuspend', {
  description = 'Lock & Suspend',
})
hl.bind('ALT + CTRL + DELETE', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call systemMonitor toggle', {
  description = 'System Monitor',
})

-- ── Audio Controls ──

hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call volume increase', {
  description = 'Raise Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call volume decrease', {
  description = 'Lower Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioMute', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call volume muteOutput', {
  description = 'Mute Audio',
  locked = true,
})
hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call volume muteInput', {
  description = 'Mute Mic',
  locked = true,
})
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call media playPause', {
  description = 'Play Audio',
  locked = true,
})
hl.bind('XF86AudioPause', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call media playPause', {
  description = 'Pause Audio',
  locked = true,
})
hl.bind('XF86AudioNext', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call media next', {
  description = 'Next Track',
  locked = true,
})
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call media previous', {
  description = 'Previous Track',
  locked = true,
})

-- ── Brightness Controls ──

hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call brightness increase', {
  description = 'Increase Brightness',
  repeating = true,
  locked = true,
})
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call brightness decrease', {
  description = 'Decrease Brightness',
  repeating = true,
  locked = true,
})

-- ── Misc Noctalia ──

hl.bind(mod .. '+ ALT + CTRL + BACKSLASH', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call idleInhibitor toggle', {
  description = 'Toggle Idle Inhibitor',
})
hl.bind(mod .. '+ SLASH', hl.dsp.exec_cmd 'qs -c noctalia-shell ipc call plugin:keybind-cheatsheet toggle', {
  description = 'Toggle Keybinds Cheatsheet',
})
