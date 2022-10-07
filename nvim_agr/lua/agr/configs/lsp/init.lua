local mason_status_ok, mason = pcall(require, 'mason')
if not mason_status_ok then return end

mason.setup {
  ui = {
    icons = {
      package_installed = '✓',
      package_uninstalled = '✗',
      package_pending = '⟳',
    },
  },
}

