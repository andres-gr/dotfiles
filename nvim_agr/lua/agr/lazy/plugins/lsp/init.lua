local L = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'jayp0521/mason-null-ls.nvim',
    'jose-elias-alvarez/typescript.nvim',
    'onsails/lspkind.nvim',
    {
      'glepnir/lspsaga.nvim',
      event = 'BufReadPre',
    },
  },
  event = 'VeryLazy',
}

L.config = function ()
  local mas = require 'agr.lazy.plugins.lsp.mason_init'
  local nls = require 'agr.lazy.plugins.lsp.null_ls'
  local saga = require 'agr.lazy.plugins.lsp.lsp_saga'

  mas.setup()
  nls.setup()
  saga.setup()
end

return L
