local T = {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring', -- Context based comments
    'hiphish/rainbow-delimiters.nvim',
    'windwp/nvim-ts-autotag',                      -- Autoclose tags
  },
  lazy = false,
}

T.config = function ()
  local treesitter = require 'nvim-treesitter'

  treesitter.setup {
    auto_install = 'true',
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
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
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
    matchup = { enable = true },
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

  vim.cmd.syntax 'off'

  vim.treesitter.language.register('bash', { 'sh', 'zsh', 'zshrc' })
end

return T
