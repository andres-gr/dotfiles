local I = {
  'lukas-reineke/indent-blankline.nvim',
  event = {
    'BufNewFile',
    'BufReadPost',
  },
  main = 'ibl',
}

I.config = function ()
  local indent_line = require 'ibl'
  local utils = require 'agr.core.utils'
  local hooks = require 'ibl.hooks'
  local colors = require 'agr.core.colors'.dracula_colors

  hooks.register(hooks.type.HIGHLIGHT_SETUP, function ()
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[1], { fg = colors.pink })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[2], { fg = colors.yellow })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[3], { fg = colors.bright_blue })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[4], { fg = colors.orange })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[5], { fg = colors.green })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[6], { fg = colors.purple })
    vim.api.nvim_set_hl(0, utils.rainbow_highlights[7], { fg = colors.cyan })
  end)

  indent_line.setup {
    exclude = {
      filetypes = {
        '',
        'aerial',
        'alpha',
        'checkhealth',
        'dashboard',
        'gitcommit',
        'help',
        'help',
        'lspinfo',
        'man',
        'neo-tree',
        'neogitstatus',
        'NvimTree',
        'packer',
        'packer',
        'startify',
        'TelescopePrompt',
        'TelescopeResults',
        'Trouble',
      },
    },
    indent = {
      char = '▏', -- ▏
    },
    scope = {
      char = '▏',
      highlight = utils.rainbow_highlights,
      include = {
        node_type = {
          ['*'] = {
            -- '^argument',
            -- '^expression',
            -- '^for',
            -- '^if',
            -- '^import',
            -- '^object',
            -- '^table',
            -- '^type',
            -- '^while',
            'arguments',
            'block',
            'bracket',
            'catch_clause',
            'class',
            'declaration',
            'else_clause',
            'field',
            'func_literal',
            'function',
            'if_statement',
            'import_spec_list',
            'import_statement',
            'jsx_element',
            'jsx_self_closing_element',
            'list',
            'method',
            'operation_type',
            'return',
            'return_statement',
            'short_var_declaration',
            'switch_body',
            'try',
            'try_statement',
          },
        },
      },
      show_start = false,
    },
  }

  hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
end

return I
