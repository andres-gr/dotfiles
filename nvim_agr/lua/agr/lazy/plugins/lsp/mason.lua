local M = {
  'williamboman/mason.nvim',
  dependencies = {
    'jayp0521/mason-null-ls.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
}

M.config = function ()
  local mason = require 'mason'

  mason.setup {
    ui = {
      icons = {
        package_installed = '✓',
        package_uninstalled = '✗',
        package_pending = '⟳',
      },
    },
  }
end

return M
