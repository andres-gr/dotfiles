local treesitter_status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not treesitter_status_ok then return end

treesitter.setup {
  auto_install = { 'true' },
  autopairs = { enable = true },
  autotag = { enable = true },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  ensure_installed = {
    'bash',
    'css',
    'html',
    'javascript',
    'json',
    'lua',
    'tsx',
    'vim',
  },
  highlight = {
    additional_vim_regex_highlighting = true,
    disable = { 'css' },
    enable = true,
  },
  indent = {
    disable = { 'css' },
    enable = true,
  },
  incremental_selection = { enable = true },
  rainbow = {
    disable = { 'html' },
    enable = true,
    extended_mode = false,
    max_file_lines = nil,
  },
}

local parser_status_ok, parser = pcall(require, 'agr.core.ts-parser')
if parser_status_ok then
  parser.directives()
  parser.queries()
end
