local indent_line_status_ok, indent_line = pcall(require, 'indent_blankline')
if not indent_line_status_ok then return end

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
    'NvimTree',
    'Trouble',
    'aerial',
    'alpha',
    'dashboard',
    'help',
    'neo-tree',
    'neogitstatus',
    'packer',
    'startify',
  },
  show_current_context = true,
  show_trailing_blankline_indent = false,
  use_treesitter = true,
}

