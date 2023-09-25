local colors = require 'agr.core.colors'.dracula_colors

local S = {}

S.setup = function ()
  local saga = require 'lspsaga'

  saga.setup {
    definition = {
      keys = {
        edit = '<CR>',
      },
    },
    finder = {
      default = 'def+ref+imp',
      keys = {
        close = 'Q',
      },
    },
    lightbulb = {
      cache_code_action = true,
      enable = true,
      enable_in_insert = false,
      update_time = 250,
      virtual_text = false,
    },
    preview = {
      lines_below = 5,
    },
    request_timeout = 2500,
    -- Keybinds for navigation in saga window
    scroll_preview = {
      scroll_down = '<C-j>',
      scroll_up = '<C-k>',
    },
    ui = {
      code_action = '', -- '󰌵', '', '', ''
      colors = {
        black = colors.bg,
        blue = colors.bright_blue,
        cyan = colors.cyan,
        green = colors.green,
        magenta = colors.bright_magenta,
        normal_bg = colors.menu,
        orange = colors.orange,
        purple = colors.purple,
        red = colors.red,
        title_bg = colors.menu,
        white = colors.fg,
        yellow = colors.yellow,
      },
    },
  }
end

return S
