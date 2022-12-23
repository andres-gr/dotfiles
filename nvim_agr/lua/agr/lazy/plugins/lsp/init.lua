local L = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'glepnir/lspsaga.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'jose-elias-alvarez/typescript.nvim',
    'onsails/lspkind.nvim',
    'williamboman/mason.nvim',
  },
  event = 'BufReadPre',
  name = 'lsp',
}

return L
