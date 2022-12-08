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
    'typescript',
    'vim',
  },
  highlight = {
    additional_vim_regex_highlighting = false,
    disable = { 'css' },
    enable = true,
  },
  indent = {
    disable = { 'css' },
    enable = true,
  },
  incremental_selection = { enable = true },
  playground = {
    enable = true,
    keybindings = {
      focus_language = 'f',
      goto_node = '<CR>',
      show_help = '?',
      toggle_anonymous_nodes = 'a',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_language_display = 'I',
      toggle_query_editor = 'o',
      unfocus_language = 'F',
      update = 'R',
    },
    persist_queries = false, -- Whether the query persists across vim sessions
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
  },
  rainbow = {
    disable = { 'html' },
    enable = true,
    extended_mode = false,
    max_file_lines = nil,
  },
}

-- local parser_status_ok, parser = pcall(require, 'agr.core.ts-parser')
-- if parser_status_ok then
--   parser.directives()
--   parser.queries()
-- end

