local S = {
  'petertriho/nvim-scrollbar',
  event = 'BufReadPost',
}

S.config = function ()
  local scrollbar = require 'scrollbar'
  local colors = require 'agr.core.colors'

  scrollbar.setup {
    excluded_buftypes = {
      'nofile',
    },
    excluded_filetypes = {
      'alpha',
      'neo-tree',
      'neo-tree-popup',
      'notify',
      'sagarename',
      'TelescopePrompt',
    },
    handle = {
      color = colors.dracula_colors.menu,
    },
    handlers = {
      gitsigns = true,
      search = true,
    },
    marks = {
      Cursor = {
        highlight = 'NeoTreeIndentMarker',
        text = '',
      },
      Search = {
        highlight = 'CmpItemKindConstant',
      },
    },
  }
end

return S
