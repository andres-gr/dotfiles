local I = {
  'lukas-reineke/indent-blankline.nvim',
  event = {
    'BufReadPost',
    'BufNewFile',
  },
}

I.config = function ()
  local indent_line = require 'indent_blankline'

  indent_line.setup {
    buftype_exclude = {
      'nofile',
      'terminal',
    },
    char = '▏',
    context_char = '▏',
    context_patterns = {
      '^for',
      '^if',
      '^object',
      '^table',
      '^while',
      'arguments',
      'block',
      'catch_clause',
      'class',
      'else_clause',
      'function',
      'if_statement',
      'import_statement',
      'jsx_element',
      'jsx_element',
      'jsx_self_closing_element',
      'method',
      'operation_type',
      'return',
      'try_statement',
    },
    filetype_exclude = {
      'aerial',
      'alpha',
      'dashboard',
      'help',
      'neo-tree',
      'neogitstatus',
      'NvimTree',
      'packer',
      'startify',
      'Trouble',
    },
    show_current_context = true,
    show_trailing_blankline_indent = false,
    use_treesitter = true,
  }
end

return I
