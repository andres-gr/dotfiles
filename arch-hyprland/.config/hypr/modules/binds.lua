-------------------------------
---- BINDS CONFIGURATION ------
-------------------------------

local mod = require 'utils.mod_key'

local dont_kill_steam = require 'utils.dont_kill_steam'
local toggle_prop = require 'utils.toggle_prop'
local workspace_clamp = require 'utils.workspace_clamp'

local apps = {
  browser = 'zen-browser',
  browser_alt = 'chromium',
  btop = 'ghostty -e zsh -c btop',
  explorer = 'dolphin',
  menu = 'fuzzel',
  terminal = 'ghostty',
  terminal_alt = 'kitty',
  terminal_no_tmux = '_NO_TMUX=1 ghostty -e zsh',
  yazi = 'ghostty -e zsh -c yazi',
}

local home = os.getenv('HOME')

local scripts = {
  screenshot = home .. '/.local/bin/screenshot-tool-agr',
}

-- 1. Window Management
hl.bind(mod .. '+ SHIFT + Q', hl.dsp.window.kill(), {
  description = 'Kill Focused Window',
})
hl.bind(mod .. '+ Q', dont_kill_steam(), {
  description = 'Close Focused Window',
})
hl.bind('ALT + F4', dont_kill_steam(), {
  description = 'Close Focused Window',
})
hl.bind(mod .. '+ D', hl.dsp.window.float { action = 'toggle' }, {
  description = 'Toggle Floating Window',
})
hl.bind(mod .. '+ G', hl.dsp.group.toggle(), {
  description = 'Toggle Group',
})
hl.bind('SHIFT + F11', hl.dsp.window.fullscreen {
  action = 'toggle',
  mode = 'maximized',
}, {
  description = 'Toggle Fullscreen',
})
hl.bind(mod .. '+ RETURN', hl.dsp.window.fullscreen {
  action = 'toggle',
  mode = 'maximized',
}, {
  description = 'Toggle Fullscreen',
})
hl.bind(mod .. '+ SHIFT + RETURN', hl.dsp.window.fullscreen {
  action = 'toggle',
  mode = 'fullscreen',
}, {
  description = 'Toggle Fullscreen (No Bar)',
})
hl.bind(mod .. '+ SHIFT + C', hl.dsp.window.center(), {
  description = 'Center Focused Window',
})
hl.bind(mod .. '+ SHIFT + M', function()
  local mon = hl.get_active_monitor()
  if mon == nil then return end

  hl.dispatch(
    hl.dsp.window.resize {
      x = math.ceil(mon.width * 0.95),
      y = math.ceil(mon.height * 0.95),
    }
  )
  hl.dispatch(
    hl.dsp.window.center()
  )
end, {
  description = 'Maximize Focused Window',
})
hl.bind(mod .. '+ SHIFT + N', function()
  local mon = hl.get_active_monitor()
  if mon == nil then return end

  hl.dispatch(
    hl.dsp.window.resize {
      x = math.ceil(mon.width * 0.65),
      y = math.ceil(mon.height * 0.85),
    }
  )
  hl.dispatch(
    hl.dsp.window.center()
  )
end, {
  description = '3/4 Focused Window',
})
hl.bind(mod .. '+ SHIFT + B', function()
  local mon = hl.get_active_monitor()
  if mon == nil then return end

  hl.dispatch(
    hl.dsp.window.resize {
      x = math.ceil(mon.width * 0.5),
      y = math.ceil(mon.height * 0.75),
    }
  )
  hl.dispatch(
    hl.dsp.window.center()
  )
end, {
  description = 'Half Focused Window',
})

hl.bind(mod .. '+ CTRL + H', hl.dsp.group.prev(), {
  description = 'Previous Group',
})
hl.bind(mod .. '+ CTRL + L', hl.dsp.group.next(), {
  description = 'Next Group',
})

-- 2. Focus Navigation
hl.bind(mod .. '+ LEFT', hl.dsp.focus { direction = 'l' }, {
  description = 'Focus Left',
})
hl.bind(mod .. '+ RIGHT', hl.dsp.focus { direction = 'r' }, {
  description = 'Focus Right',
})
hl.bind(mod .. '+ UP', hl.dsp.focus { direction = 'u' }, {
  description = 'Focus Up',
})
hl.bind(mod .. '+ DOWN', hl.dsp.focus { direction = 'd' }, {
  description = 'Focus Down',
})
hl.bind('ALT + TAB', hl.dsp.window.cycle_next(), {
  description = 'Cycle Focus',
})
hl.bind('ALT + SHIFT + TAB', hl.dsp.window.cycle_next { next = 'prev' }, {
  description = 'Cycle Focus (Backwards)',
})
hl.bind(mod .. '+ H', hl.dsp.focus { direction = 'l' }, {
  description = 'Focus Left (Vim)',
})
hl.bind(mod .. '+ L', hl.dsp.focus { direction = 'r' }, {
  description = 'Focus Right (Vim)',
})
hl.bind(mod .. '+ K', hl.dsp.focus { direction = 'u' }, {
  description = 'Focus Up (Vim)',
})
hl.bind(mod .. '+ J', hl.dsp.focus { direction = 'd' }, {
  description = 'Focus Down (Vim)',
})

-- 3. Window Movement
hl.bind(mod .. '+ SHIFT + H', hl.dsp.window.move { direction = 'l' }, {
  description = 'Move Window Left (Vim)',
})
hl.bind(mod .. '+ SHIFT + L', hl.dsp.window.move { direction = 'r' }, {
  description = 'Move Window Right (Vim)',
})
hl.bind(mod .. '+ SHIFT + K', hl.dsp.window.move { direction = 'u' }, {
  description = 'Move Window Up (Vim)',
})
hl.bind(mod .. '+ SHIFT + J', hl.dsp.window.move { direction = 'd' }, {
  description = 'Move Window Down (Vim)',
})
hl.bind(mod .. '+ CTRL + SHIFT + LEFT', hl.dsp.window.move { direction = 'l' }, {
  description = 'Move Active Window Left',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + SHIFT + RIGHT', hl.dsp.window.move { direction = 'r' }, {
  description = 'Move Active Window Right',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + SHIFT + UP', hl.dsp.window.move { direction = 'u' }, {
  description = 'Move Active Window Up',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + SHIFT + DOWN', hl.dsp.window.move { direction = 'd' }, {
  description = 'Move Active Window Down',
  repeating = true,
})
hl.bind(mod .. '+ mouse:272', hl.dsp.window.drag(), {
  description = 'Hold To Move Window',
  mouse = true,
})
hl.bind(mod .. '+ Z', hl.dsp.window.drag(), {
  description = 'Hold To Move Window (Key)',
  mouse = true,
})
hl.bind('F20', hl.dsp.window.drag(), {
  description = 'Hold To Move Window (Key)',
  mouse = true,
})

-- 4. Window Resizing
hl.bind(mod .. '+ SHIFT + RIGHT', hl.dsp.window.resize {
  x = 30,
  y = 0,
  relative = true,
}, {
  description = 'Resize Window Right',
  repeating = true,
})
hl.bind(mod .. '+ SHIFT + LEFT', hl.dsp.window.resize {
  x = -30,
  y = 0,
  relative = true,
}, {
  description = 'Resize Window Left',
  repeating = true,
})
hl.bind(mod .. '+ SHIFT + UP', hl.dsp.window.resize {
  x = 0,
  y = -30,
  relative = true,
}, {
  description = 'Resize Window Up',
  repeating = true,
})
hl.bind(mod .. '+ SHIFT + DOWN', hl.dsp.window.resize {
  x = 0,
  y = 30,
  relative = true,
}, {
  description = 'Resize Window Down',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + H', hl.dsp.window.resize {
  x = -30,
  y = 0,
  relative = true,
}, {
  description = 'Resize Window Left (Vim)',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + L', hl.dsp.window.resize {
  x = 30,
  y = 0,
  relative = true,
}, {
  description = 'Resize Window Right (Vim)',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + K', hl.dsp.window.resize {
  x = 0,
  y = -30,
  relative = true,
}, {
  description = 'Resize Window Up (Vim)',
  repeating = true,
})
hl.bind(mod .. '+ CTRL + J', hl.dsp.window.resize {
  x = 0,
  y = 30,
  relative = true,
}, {
  description = 'Resize Window Down (Vim)',
  repeating = true,
})
hl.bind(mod .. '+ mouse:273', hl.dsp.window.resize(), {
  description = 'Hold To Resize Window',
  mouse = true,
})
hl.bind(mod .. '+ SHIFT + Z', hl.dsp.window.resize(), {
  description = 'Hold To Resize Window (Key)',
  mouse = true,
})
hl.bind('SHIFT + F20', hl.dsp.window.resize(), {
  description = 'Hold To Resize Window (Key)',
  mouse = true,
})

-- 5. Layouts and Window Props
hl.bind(mod .. '+ ALT + BACKSLASH', hl.dsp.layout 'togglesplit', {
  description = 'Toggle Split',
})
hl.bind(mod .. '+ P', hl.dsp.window.pseudo(), {
  description = 'Toggle Pseudo',
})
hl.bind(mod .. '+ U', toggle_prop.opaque, {
  description = 'Toggle Opacity',
})
hl.bind(mod .. '+ ALT + U', toggle_prop.no_blur, {
  description = 'Toggle Blur',
})

-- 6. Applications
hl.bind(mod .. '+ T', hl.dsp.exec_cmd(apps.terminal_no_tmux), {
  description = 'Terminal (No Tmux)',
})
hl.bind(mod .. '+ CTRL + T', hl.dsp.exec_cmd(apps.terminal), {
  description = 'Terminal',
})
hl.bind(mod .. '+ SHIFT + T', hl.dsp.exec_cmd(apps.terminal_alt), {
  description = 'Alt Terminal',
})
hl.bind(mod .. '+ E', hl.dsp.exec_cmd(apps.explorer), {
  description = 'File Explorer',
})
hl.bind(mod .. '+ Y', hl.dsp.exec_cmd(apps.yazi), {
  description = 'File Explorer (Yazi)',
})
hl.bind(mod .. '+ B', hl.dsp.exec_cmd(apps.browser), {
  description = 'Browser',
})
hl.bind(mod .. '+ CTRL + B', hl.dsp.exec_cmd(apps.browser_alt), {
  description = 'Alt Browser',
})
hl.bind('ALT + SPACE', hl.dsp.exec_cmd(apps.menu), {
  description = 'Application Finder',
})
hl.bind('CTRL + SHIFT + ESCAPE', hl.dsp.exec_cmd(apps.btop), {
  description = 'Btop Process Monitor',
})


-- 7. Workspaces
local workspaces = {
  { key = '1', ws = 1 },
  { key = '2', ws = 2 },
  { key = '3', ws = 3 },
  { key = '4', ws = 4 },
  { key = '5', ws = 5 },
  { key = '6', ws = 6 },
  { key = '7', ws = 7 },
  { key = '8', ws = 8 },
}

for _, ws in ipairs(workspaces) do
  hl.bind(mod .. '+' .. ws.key, hl.dsp.focus { workspace = ws.ws }, {
    description = 'Navigate To Workspace ' .. ws.ws,
  })
end

hl.bind(mod .. '+ CTRL + RIGHT', workspace_clamp 'next', {
  description = 'Next Workspace',
})
hl.bind(mod .. '+ CTRL + LEFT', workspace_clamp 'prev', {
  description = 'Previous Workspace',
})
hl.bind(mod .. '+ CTRL + DOWN', hl.dsp.focus { workspace = 'empty' }, {
  description = 'Nearest Empty Workspace',
})
hl.bind(mod .. '+ mouse_down', workspace_clamp 'next', {
  description = 'Next Workspace (Mouse)',
})
hl.bind(mod .. '+ mouse_up', workspace_clamp 'prev', {
  description = 'Previous Workspace (Mouse)',
})
hl.bind(mod .. '+ PERIOD', workspace_clamp 'next', {
  description = 'Next Workspace (Key)',
})
hl.bind(mod .. '+ COMMA', workspace_clamp 'prev', {
  description = 'Previous Workspace (Key)',
})
hl.bind(mod .. '+ TAB', hl.dsp.focus { workspace = 'm+1' }, {
  description = 'Next Workspace (Tab)',
})
hl.bind(mod .. '+ SHIFT + TAB', hl.dsp.focus { workspace = 'm-1' }, {
  description = 'Previous Workspace (Tab)',
})
hl.bind(mod .. '+ CTRL + BRACKETRIGHT', workspace_clamp 'next', {
  description = 'Next Workspace (Bracket)',
})
hl.bind(mod .. '+ CTRL + BRACKETLEFT', workspace_clamp 'prev', {
  description = 'Previous Workspace (Bracket)',
})

for _, ws in ipairs(workspaces) do
  hl.bind(mod .. '+ SHIFT + ' .. ws.key, hl.dsp.window.move { workspace = ws.ws }, {
    description = 'Move To Workspace ' .. ws.ws,
  })
end

hl.bind(mod .. '+ ALT + CTRL + RIGHT', workspace_clamp('next', 'move'), {
  description = 'Move To Next Workspace',
})
hl.bind(mod .. '+ ALT + CTRL + LEFT', workspace_clamp('prev', 'move'), {
  description = 'Move To Previous Workspace',
})
hl.bind(mod .. '+ SHIFT + PERIOD', workspace_clamp('next', 'move'), {
  description = 'Move To Next Workspace (Key)',
})
hl.bind(mod .. '+ SHIFT + COMMA', workspace_clamp('prev', 'move'), {
  description = 'Move To Previous Workspace (Key)',
})
hl.bind(mod .. '+ CTRL + SHIFT + BRACKETRIGHT', workspace_clamp('next', 'move'), {
  description = 'Move To Next Workspace (Bracket)',
})
hl.bind(mod .. '+ CTRL + SHIFT + BRACKETLEFT', workspace_clamp('prev', 'move'), {
  description = 'Move To Previous Workspace (Bracket)',
})

for _, ws in ipairs(workspaces) do
  hl.bind(mod .. '+ ALT + ' .. ws.key, hl.dsp.window.move {
    workspace = ws.ws,
    follow = false,
  }, {
    description = 'Move To Workspace ' .. ws.ws .. ' (Silent)',
  })
end

hl.bind(mod .. '+ ALT + PERIOD', workspace_clamp('next', 'movesilent'), {
  description = 'Move To Next Workspace (Silent)',
})
hl.bind(mod .. '+ ALT + COMMA', workspace_clamp('prev', 'movesilent'), {
  description = 'Move To Previous Workspace (Silent)',
})
hl.bind(mod .. '+ ALT + CTRL + BRACKETRIGHT', workspace_clamp('next', 'movesilent'), {
  description = 'Move To Next Workspace (Silent) (Bracket)',
})
hl.bind(mod .. '+ ALT + CTRL + BRACKETLEFT', workspace_clamp('prev', 'movesilent'), {
  description = 'Move To Previous Workspace (Silent) (Bracket)',
})

-- 8. Scratchpads
hl.bind(mod .. '+ SHIFT + S', hl.dsp.window.move { workspace = 'special' }, {
  description = 'Move To Scratchpad',
})
hl.bind(mod .. '+ ALT + S', hl.dsp.window.move {
  workspace = 'special',
  follow = false,
}, {
  description = 'Move To Scratchpad (Silent)',
})
hl.bind(mod .. '+ S', hl.dsp.workspace.toggle_special(), {
  description = 'Toggle Scratchpad',
})

-- 9. Minimized Workspace
hl.bind(mod .. '+ X', hl.dsp.window.move {
  workspace = 'special:minimized',
  follow = false,
}, {
  description = 'Send to minimized workspace',
})
hl.bind(mod .. '+ SHIFT + X', hl.dsp.workspace.toggle_special 'minimized', {
  description = 'Toggle minimized workspace',
})
hl.bind(mod .. '+ CTRL + X', hl.dsp.window.move { workspace = '+0' }, {
  description = 'Move from minimized workspace',
})

-- 10. Monitor Focus and Navigation
hl.bind(mod .. '+ I', hl.dsp.focus { monitor = 'l' }, {
  description = 'Focus Left Monitor',
})
hl.bind(mod .. '+ O', hl.dsp.focus { monitor = 'r' }, {
  description = 'Focus Right Monitor',
})

hl.bind(mod .. '+ SHIFT + I', hl.dsp.window.move { monitor = 'l' }, {
  description = 'Move Window To Left Monitor',
})
hl.bind(mod .. '+ SHIFT + O', hl.dsp.window.move { monitor = 'r' }, {
  description = 'Move Window To Right Monitor',
})

hl.bind(mod .. '+ ALT + I', hl.dsp.window.move {
  monitor = 'l',
  follow = false,
}, {
  description = 'Move Window To Left Monitor (Silent)',
})
hl.bind(mod .. '+ ALT + O', hl.dsp.window.move {
  monitor = 'r',
  follow = false,
}, {
  description = 'Move Window To Right Monitor (Silent)',
})

-- 11. Hardware Controls
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd 'pamixer -i 2', {
  description = 'Raise Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd 'pamixer -d 2', {
  description = 'Lower Volume',
  repeating = true,
  locked = true,
})
hl.bind('XF86AudioMute', hl.dsp.exec_cmd 'pamixer -t', {
  description = 'Mute Volume',
  locked = true,
})
hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd 'pamixer --default-source -m', {
  description = 'Mute Microphone',
  locked = true,
})
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd 'playerctl play-pause', {
  description = 'Play',
  locked = true,
})
hl.bind('XF86AudioPause', hl.dsp.exec_cmd 'playerctl play-pause', {
  description = 'Pause',
  locked = true,
})
hl.bind('XF86AudioNext', hl.dsp.exec_cmd 'playerctl next', {
  description = 'Next Track',
  locked = true,
})
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd 'playerctl previous', {
  description = 'Previous Track',
  locked = true,
})

-- 12. Screenshots
hl.bind('Print', hl.dsp.exec_cmd(scripts.screenshot .. ' region'), {
  description = 'Screenshot Region',
})
hl.bind('SHIFT + Print', hl.dsp.exec_cmd(scripts.screenshot .. ' window'), {
  description = 'Screenshot Window',
})
hl.bind('CTRL + Print', hl.dsp.exec_cmd(scripts.screenshot .. ' screen'), {
  description = 'Screenshot Screen',
})
hl.bind(mod .. '+ Print', hl.dsp.exec_cmd(scripts.screenshot .. ' full'), {
  description = 'Screenshot All Monitors',
})

-- 13. Misc
hl.bind(mod .. '+ ALT + CTRL + BACKSPACE', hl.dsp.exit(), {
  description = 'Quit Hyprland',
})
