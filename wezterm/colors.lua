local dracula = {
  bg = '#22212C',
  fg = '#F8F8F2',
  selection = '#454158',
  comment = '#7970A9',
  red = '#FF9580',
  orange = '#FFCA80',
  yellow = '#FFFF80',
  green = '#8AFF80',
  purple = '#9580FF',
  cyan = '#80FFEA',
  pink = '#FF80BF',
  bright_red = '#FFBFB3',
  bright_green = '#B9FFB3',
  bright_yellow = '#FFFFB3',
  bright_blue = '#BFB3FF',
  bright_magenta = '#FFB3D9',
  bright_cyan = '#B3FFF2',
  bright_white = '#FFFFFF',
  menu = '#2B2640',
  visual = '#424450',
  gutter_fg = '#4B5263',
  nontext = '#3B4048',
  gray = '#666666',
  none = 'NONE',
}

local dracula_colors = {
  -- The default text color
  foreground = dracula.fg,
  -- The default background color
  background = dracula.bg,

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = dracula.bright_magenta,
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = dracula.bg,
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = dracula.bright_cyan,

  -- the foreground color of selected text
  selection_fg = dracula.none,
  -- the background color of selected text
  selection_bg = 'rgba(75, 82, 99, 0.5)',

  -- The color of the scrollbar 'thumb'; the portion that represents the current viewport
  scrollbar_thumb = dracula.gutter_fg,

  -- The color of the split lines between panes
  split = dracula.gray,

  ansi = {
    dracula.bg,
    dracula.red,
    dracula.green,
    dracula.yellow,
    dracula.purple,
    dracula.pink,
    dracula.cyan,
    dracula.fg,
  },
  brights = {
    dracula.gray,
    dracula.bright_red,
    dracula.bright_cyan,
    dracula.bright_yellow,
    dracula.bright_blue,
    dracula.bright_magenta,
    dracula.bright_cyan,
    dracula.bright_white,
  },

  -- Since: nightly builds only
  -- When the IME, a dead key or a leader key are being processed and are effectively
  -- holding input pending the result of input composition, change the cursor
  -- to this color to give a visual cue about the compose state.
  -- compose_cursor = '#FFB86C',

  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = dracula.bg,

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = dracula.bright_blue,
      -- The color of the text for the tab
      fg_color = dracula.bg,

      -- Specify whether you want 'Half', 'Normal' or 'Bold' intensity for the
      -- label shown for this tab.
      -- The default is 'Normal'
      intensity = 'Normal',

      -- Specify whether you want 'None', 'Single' or 'Double' underline for
      -- label shown for this tab.
      -- The default is 'None'
      underline = 'None',

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab.  The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab.  The default is false.
      strikethrough = false
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = dracula.bg,
      fg_color = dracula.fg

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = dracula.gray,
      fg_color = dracula.fg,
      italic = true

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab_hover`.
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = dracula.bg,
      fg_color = dracula.fg

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = dracula.pink,
      fg_color = dracula.fg,
      italic = true

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab_hover`.
    },
  },
}

return dracula_colors
