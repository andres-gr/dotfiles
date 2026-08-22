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

local noct_ipc = 'noctalia msg'

-- 16. Noctalia Launchers
hl.bind('ALT + SPACE', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle launcher'), {
  description = 'Application Launcher',
})
hl.bind(mod .. '+ Z', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle control-center'), {
  description = 'Control Center',
})
hl.bind(mod .. '+ SHIFT + E', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle launcher /emo'), {
  description = 'Emoji Picker',
})
hl.bind(mod .. '+ V', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle clipboard'), {
  description = 'Clipboard Manager',
})
hl.bind(mod .. '+ SHIFT + BACKSPACE', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle session'), {
  description = 'Power Menu: Toggle',
})
hl.bind(mod .. '+ N', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle control-center notifications'), {
  description = 'Notification Center',
})
hl.bind(mod .. '+ ALT + N', hl.dsp.exec_cmd(noct_ipc .. ' notification-clear-history'), {
  description = 'Notifications: Clear All',
})
hl.bind(mod .. '+ CTRL + N', hl.dsp.exec_cmd(noct_ipc .. ' notification-clear-active'), {
  description = 'Notifications: Dismiss All',
})

-- 17. Noctalia Session Controls
hl.bind(mod .. '+ ALT + CTRL + L', hl.dsp.exec_cmd(noct_ipc .. ' session lock'), {
  description = 'Lock Screen',
})
hl.bind(mod .. '+ CTRL + SHIFT + L', hl.dsp.exec_cmd(noct_ipc .. ' session lock-and-suspend'), {
  description = 'Lock & Suspend',
})

-- 18. Noctalia Hardware Controls
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(noct_ipc .. ' volume-up 2'), {
  description = 'Raise Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(noct_ipc .. ' volume-down 2'), {
  description = 'Lower Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(noct_ipc .. ' volume-mute'), {
  description = 'Mute Audio',
  locked = true,
})
hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd(noct_ipc .. ' mic-mute'), {
  description = 'Mute Mic',
  locked = true,
})
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd(noct_ipc .. ' media toggle'), {
  description = 'Play Audio',
  locked = true,
})
hl.bind('XF86AudioPause', hl.dsp.exec_cmd(noct_ipc .. ' media toggle'), {
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

hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd(noct_ipc .. ' brightness-up'), {
  description = 'Increase Brightness',
  repeating = true,
  locked = true,
})
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd(noct_ipc .. ' brightness-down'), {
  description = 'Decrease Brightness',
  repeating = true,
  locked = true,
})

-- 19. Noctalia Extras
hl.bind(mod .. '+ ALT + CTRL + BACKSLASH', hl.dsp.exec_cmd(noct_ipc .. ' caffeine-toggle'), {
  description = 'Toggle Idle Inhibitor',
})
hl.bind(mod .. '+ ALT + CTRL + W', hl.dsp.exec_cmd(noct_ipc .. ' wallpaper-random'), {
  description = 'Random Wallpaper',
})
hl.bind(mod .. '+ ALT + CTRL + U', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle yuuto/arch-updater:panel'), {
  description = 'Check System Updates',
})
hl.bind(mod .. '+ SLASH', hl.dsp.exec_cmd(noct_ipc .. ' panel-toggle kenn/keybind-cheatsheet:cheatsheet'), {
  description = 'Toggle Keybinds Cheatsheet',
})
