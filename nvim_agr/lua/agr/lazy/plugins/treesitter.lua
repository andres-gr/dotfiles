local T = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring', -- Context based comments
    'hiphish/rainbow-delimiters.nvim',
    'windwp/nvim-ts-autotag',                      -- Autoclose tags
    'nvim-treesitter/playground',                  -- TS playground
  },
  event = {
    'BufNewFile',
    'BufReadPre',
  },
  version = false,
}

T.config = function ()
  local treesitter = require 'nvim-treesitter.configs'

  treesitter.setup {
    auto_install = { 'true' },
    autopairs = { enable = true },
    ensure_installed = {
      'bash',
      'css',
      'html',
      'javascript',
      'json',
      'lua',
      'markdown',
      'markdown_inline',
      'styled',
      'tsx',
      'typescript',
      'vim',
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-S>',
        node_decremental = '<BS>',
        node_incremental = '<C-S>',
        scope_incremental = false,
      },
    },
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
      updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
    },
  }

  -- Add mdx highlight
  vim.treesitter.language.register('markdown', 'mdx')

  local rainbow = require 'rainbow-delimiters'
  local utils = require 'agr.core.utils'

  vim.g.rainbow_delimiters = {
    highlight = utils.rainbow_highlights,
    query = {
      [''] = 'rainbow-delimiters',
      javascript = 'rainbow-parens',
      jsx = 'rainbow-parens',
      lua = 'rainbow-blocks',
      tsx = 'rainbow-parens',
      typescript = 'rainbow-parens',
    },
    strategy = {
      [''] = rainbow.strategy['global'],
      html = rainbow.strategy['local'],
    },
  }

  vim.g.skip_ts_context_commentstring_module = true

  local commentstring = require 'ts_context_commentstring'

  commentstring.setup {
    enable_autocmd = true,
  }

  local autotag = require 'nvim-ts-autotag'

  autotag.setup {
    opts = {
      enable_close = true,
      enable_close_on_slash = true,
      enable_rename = true,
    },
  }
end

return T
