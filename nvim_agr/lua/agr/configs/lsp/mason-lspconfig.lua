local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_status_ok then return end

local lspconfig_status_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_status_ok then return end

local handlers = require 'agr.configs.lsp.handlers'

mason_lspconfig.setup {
  ensure_installed = {
    'bashls',
    'cssls',
    'graphql',
    'html',
    'jsonls',
    'sumneko_lua',
    'tsserver',
    'vimls',
    'yamlls',
  },
}

handlers.setup()

local opts = {
  capabilities = handlers.capabilities,
  on_attach = handlers.on_attach,
  root_dir = handlers.root_dir,
}

mason_lspconfig.setup_handlers {
  -- default handler
  function (server_name)
    lspconfig[server_name].setup {
      capabilities = handlers.capabilities,
      on_attach = handlers.on_attach,
    }
  end,

  ['jsonls'] = function ()
    lspconfig.jsonls.setup(vim.tbl_deep_extend('force', require 'agr.configs.lsp.server_settings.jsonls', opts))
  end,
  ['sumneko_lua'] = function ()
    lspconfig.sumneko_lua.setup(vim.tbl_deep_extend('force', require 'agr.configs.lsp.server_settings.sumneko_lua', opts))
  end,
}

