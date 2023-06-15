local T = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  cmd = {
    'TSDisableAll',
    'TSEnableAll',
    'TSInstall',
    'TSInstallInfo',
    'TSInstallSync',
    'TSUninstall',
    'TSUpdate',
    'TSUpdateSync',
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-angular',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/playground',
    'mrjones2014/nvim-ts-rainbow',
    'windwp/nvim-ts-autotag',
  },
  event = {
    'BufNewFile',
    'BufRead',
  },
}

T.config = function ()
  local treesitter = require 'nvim-treesitter.configs'

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
      'markdown',
      'markdown_inline',
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
end

return T
