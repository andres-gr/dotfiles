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

local noct_ipc = 'qs -c noctalia-shell ipc call'

-- 16. Noctalia Launchers
hl.bind('ALT + SPACE', hl.dsp.exec_cmd(noct_ipc .. ' launcher toggle'), {
  description = 'Application Launcher',
})
hl.bind(mod .. '+ S', hl.dsp.exec_cmd(noct_ipc .. ' controlCenter toggle'), {
  description = 'Control Center',
})
hl.bind(mod .. '+ SHIFT + S', hl.dsp.exec_cmd(noct_ipc .. ' launcher emoji'), {
  description = 'Emoji Picker',
})
hl.bind(mod .. '+ V', hl.dsp.exec_cmd(noct_ipc .. ' launcher clipboard'), {
  description = 'Clipboard Manager',
})
hl.bind(mod .. '+ SHIFT + BACKSPACE', hl.dsp.exec_cmd(noct_ipc .. ' sessionMenu toggle'), {
  description = 'Power Menu: Toggle',
})
hl.bind(mod .. '+ N', hl.dsp.exec_cmd(noct_ipc .. ' notifications toggleHistory'), {
  description = 'Notification Center',
})
hl.bind(mod .. '+ ALT + N', hl.dsp.exec_cmd(noct_ipc .. ' notifications clear'), {
  description = 'Notifications: Clear All',
})
hl.bind(mod .. '+ CTRL + N', hl.dsp.exec_cmd(noct_ipc .. ' notifications dismissAll'), {
  description = 'Notifications: Dismiss All',
})

-- 17. Noctalia Session Controls
hl.bind(mod .. '+ ALT + CTRL + L', hl.dsp.exec_cmd(noct_ipc .. ' lockScreen lock'), {
  description = 'Lock Screen',
})
hl.bind('ALT + CTRL + SHIFT + L', hl.dsp.exec_cmd(noct_ipc .. ' sessionMenu lockAndSuspend'), {
  description = 'Lock & Suspend',
})
hl.bind('ALT + CTRL + DELETE', hl.dsp.exec_cmd(noct_ipc .. ' systemMonitor toggle'), {
  description = 'System Monitor',
})

-- 18. Noctalia Hardware Controls
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(noct_ipc .. ' volume increase'), {
  description = 'Raise Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(noct_ipc .. ' volume decrease'), {
  description = 'Lower Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(noct_ipc .. ' volume muteOutput'), {
  description = 'Mute Audio',
  locked = true,
})
hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd(noct_ipc .. ' volume muteInput'), {
  description = 'Mute Mic',
  locked = true,
})
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd(noct_ipc .. ' media playPause'), {
  description = 'Play Audio',
  locked = true,
})
hl.bind('XF86AudioPause', hl.dsp.exec_cmd(noct_ipc .. ' media playPause'), {
  description = 'Pause Audio',
  locked = true,
})
hl.bind('XF86AudioNext', hl.dsp.exec_cmd(noct_ipc .. ' media next'), {
  description = 'Next Track',
  locked = true,
})
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd(noct_ipc .. ' media previous'), {
  description = 'Previous Track',
  locked = true,
})

hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd(noct_ipc .. ' brightness increase'), {
  description = 'Increase Brightness',
  repeating = true,
  locked = true,
})
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd(noct_ipc .. ' brightness decrease'), {
  description = 'Decrease Brightness',
  repeating = true,
  locked = true,
})

-- 19. Noctalia Extras
hl.bind(mod .. '+ ALT + CTRL + BACKSLASH', hl.dsp.exec_cmd(noct_ipc .. ' idleInhibitor toggle'), {
  description = 'Toggle Idle Inhibitor',
})
hl.bind(mod .. '+ SLASH', hl.dsp.exec_cmd(noct_ipc .. ' plugin:keybind-cheatsheet toggle'), {
  description = 'Toggle Keybinds Cheatsheet',
})
hl.bind(mod .. '+ ALT + CTRL + U', hl.dsp.exec_cmd(noct_ipc .. ' plugin:update-count run'), {
  description = 'Run System Update',
})
