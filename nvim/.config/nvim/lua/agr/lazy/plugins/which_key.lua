local W = {
  'folke/which-key.nvim',
  event = 'VeryLazy',
}

W.config = function ()
  local which_key = require 'which-key'

  local show = which_key.show

  which_key.show = function (keys, opts)
    if vim.bo.filetype ~= 'TelescopePrompt' then
      show(keys, opts)
    end
  end

  which_key.setup {
    delay = 400,
    disable = {
      ft = {
        'TelescopePrompt',
      },
    },
    filter = function ()
      return true
    end, -- enable this to hide mappings for which you didn't specify a label
    keys = {
      scroll_down = '<C-d>', -- binding to scroll down inside the popup
      scroll_up = '<C-u>', -- binding to scroll up inside the popup
    },
    layout = {
      align = 'center', -- align columns left, center or right
      height = {
        max = 25,
        min = 4,
      }, -- min and max height of the columns
      spacing = 8, -- spacing between columns
      width = {
        max = 50,
        min = 20,
      }, -- min and max width of the columns
    },
    plugins = {
      presets = {
        operators = false,
      },
    },
    preset = 'modern',
    show_help = true, -- show help message on the command line when the popup is visible
    win = {
      border = 'rounded',
      no_overlap = true,
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      wo = {
        winblend = 0,
      },
    },
  }
end

return W
