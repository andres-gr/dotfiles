local L = {
  'neovim/nvim-lspconfig',
  branch = 'master',
  cmd = 'Mason',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'nvimtools/none-ls.nvim',
    'jayp0521/mason-null-ls.nvim',
    'onsails/lspkind.nvim',
    {
      'nvimdev/lspsaga.nvim',
      event = 'LspAttach',
    },
  },
  event = {
    'BufNewFile',
    'BufReadPre',
  },
}

L.config = function ()
  local mas = require 'agr.lazy.plugins.lsp.mason_init'
  local saga = require 'agr.lazy.plugins.lsp.lsp_saga'

  mas.setup()
  saga.setup()
end

return L
