local L = {
  'neovim/nvim-lspconfig',
  cmd = 'Mason',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    {
      'mason-org/mason.nvim',
      version = '1.11.0',
    },
    {
      'mason-org/mason-lspconfig.nvim',
      version = '1.32.0',
    },
    'nvimtools/none-ls.nvim',
    'jayp0521/mason-null-ls.nvim',
    'onsails/lspkind.nvim',
    {
      'nvimdev/lspsaga.nvim',
      event = 'LspAttach',
    },
    'pmizio/typescript-tools.nvim',
  },
  event = {
    'BufNewFile',
    'BufReadPre',
  },
  version = '*'
}

L.config = function ()
  local mas = require 'agr.lazy.plugins.lsp.mason_init'
  local saga = require 'agr.lazy.plugins.lsp.lsp_saga'

  mas.setup()
  saga.setup()
end

return L
