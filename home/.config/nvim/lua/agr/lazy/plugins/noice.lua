local N = {
  'folke/noice.nvim',
  event = 'VeryLazy',
}

N.config = function ()
  local noice = require 'noice'

  noice.setup {
    cmdline = {
      format = {
        bash = {
          kind = 'bash',
          pattern = '^:!',
          icon = '$',
          lang = 'bash',
        },
        search_and_replace = {
          kind = 'replace',
          pattern = '^:%%?s/',
          icon = ' ',
          lang = 'regex',
        },
        search_and_replace_range = {
          kind = 'replace',
          pattern = "^:'<,'>%%?s/",
          icon = ' ',
          lang = 'regex',
        },
      },
    },
    lsp = {
      hover = {
        enabled = false,
      },
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['cmp.entry.get_documentation'] = true,
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      signature = {
        enabled = false,
      },
    },
    presets = {
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    routes = {
      {
        filter = {
          event = 'notify',
          find = 'No information available',
        },
        opts = { skip = true },
      },
    },
    throttle = 1000 / 120,
    views = {
      cmdline_popup = {
        position = {
          col = '50%',
          row = '35%',
        },
        size = {
          height = 'auto',
          width = 60,
        },
      },
      mini = {
        win_options = {
          winblend = 0,
        },
      },
      popupmenu = {
        border = {
          padding = { 0, 1 },
          style = 'rounded',
        },
        position = {
          col = '50%',
          row = '44%',
        },
        relative = 'editor',
        size = {
          height = 10,
          width = 60,
        },
        win_options = {
          winhighlight = {
            FloatBorder = 'DiagnosticInfo',
            Normal = 'Normal',
          },
        },
      },
    },
  }
end

return N
