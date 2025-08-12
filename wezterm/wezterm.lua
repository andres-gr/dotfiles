local wezterm = require 'wezterm'

local W = {}

-- Use config builder object if possible
if wezterm.config_builder then W = wezterm.config_builder() end

-- Set dracula colors
local colors = require 'colors'
W.colors = colors

-- Set font options
W.font = wezterm.font_with_fallback {
  -- {
  --   family = 'MonoLisa Nerd Font',
  --   weight = 500,
  -- },
  {
    family = 'LigaOperatorMono Nerd Font',
    weight = 300,
  },
  {
    family = 'FiraCode Nerd Font',
    weight = 'DemiLight',
  },
}

W.font_size = 14.0
-- W.cell_width = 1.0
-- W.line_height = 1.0
W.underline_position = -2

-- Window options
W.enable_tab_bar = false
W.hide_tab_bar_if_only_one_tab = true
W.macos_window_background_blur = 10
W.window_background_opacity = 0.9
W.window_decorations = 'RESIZE'
W.window_padding = {
  bottom = 2,
  left = 8,
  right = 8,
  top = 2,
}
-- local gradient = require 'gradient'
-- W.window_background_gradient = gradient

-- Cursor
-- W.cursor_blink_ease_in = 'Ease'
-- W.cursor_blink_ease_out = 'Ease'
W.cursor_blink_rate = 500
W.force_reverse_video_cursor = true

-- Keybinds
local act = wezterm.action

W.keys = {
  {
    key = 'Enter',
    mods = 'ALT',
    action = act.DisableDefaultAssignment,
  },
}

-- Set UI render options
W.front_end = 'WebGpu'

-- Maximize screen on startup
-- local mux = wezterm.mux
-- wezterm.on('gui-startup', function (cmd)
--   local _, _, window = mux.spawn_window(cmd or {})
--   window:gui_window():maximize()
-- end)

W.max_fps = 120

return W
