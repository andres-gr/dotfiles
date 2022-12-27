local B = {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  version = '3.*',
}

B.config = function ()
  local bufferline = require 'bufferline'

  bufferline.setup {
    options = {
      -- always_show_bufferline = true,
      diagnostics = false, -- | 'nvim_lsp' | 'coc',
      diagnostics_update_in_insert = false,
      close_command = 'Bdelete! %d', -- can be a string | function, see 'Mouse actions'
      enforce_regular_tabs = true,
      left_mouse_command = 'buffer %d', -- can be a string | function, see 'Mouse actions'
      max_name_length = 14,
      max_prefix_length = 13,
      middle_mouse_command = nil, -- can be a string | function, see 'Mouse actions'
      numbers = 'none', -- | 'ordinal' | 'buffer_id' | 'both' | function({ ordinal, id, lower, raise }): string,
      offsets = {
        {
          filetype = 'NvimTree',
          padding = 1,
          text = 'File Explorer',
        },
        {
          filetype = 'neo-tree',
          padding = 1,
          text = 'File Explorer',
        },
        {
          filetype = 'Outline',
          padding = 1,
          text = '',
        },
      },
      persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
      -- can also be a table containing 2 custom separators
      -- [focused and unfocused]. eg: { '|', '|' }
      right_mouse_command = 'Bdelete! %d', -- can be a string | function, see 'Mouse actions'
      separator_style = {
        '▎',
        ' ',
      },
      show_buffer_close_icons = false,
      show_buffer_icons = true,
      show_close_icon = false,
      show_tab_indicators = false,
      tab_size = 20,
    },
  }
end

return B
