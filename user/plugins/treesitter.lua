local treesitter = {
  auto_install = { 'true' },
  ensure_installed = {
    'css',
    'html',
    'json',
    'lua',
    'tsx',
    'vim',
  },
  highlight = {
    additional_vim_regex_highlighting = true,
    disable = { 'css' },
  },
  indent = { enable = true },
}

return treesitter

