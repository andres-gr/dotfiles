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
      debounce = 500,
      enable_in_insert = false,
      virtual_text = false,
    },
    -- Keybinds for navigation in saga window
    scroll_preview = {
      scroll_down = '<C-j>',
      scroll_up = '<C-k>',
    },
    ui = {
      border = 'rounded',
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

  -- Lspsaga opens the rename prompt in Select mode (rename.in_select defaults
  -- to true) but only installs its exec/quit keys for insert, normal and
  -- visual modes. Leave Select mode first so those normal-mode maps can run.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'sagarename',
    callback = function (args)
      vim.keymap.set('s', '<CR>', '<Esc><CR>', {
        buffer = args.buf,
        remap = true,
        desc = 'Confirm LSP rename',
      })
      vim.keymap.set('s', '<C-k>', '<Esc><C-k>', {
        buffer = args.buf,
        remap = true,
        desc = 'Cancel LSP rename',
      })
    end,
  })
end

return S
