local M = {}

M.setup = function ()
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

  local lspconfig = require 'agr.lazy.plugins.lsp.mason_lspconfig'

  lspconfig.setup()

  local nls = require 'agr.lazy.plugins.lsp.mason_null_ls'

  nls.setup()
end

return M
