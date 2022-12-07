local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_status_ok then return end

local lspconfig_status_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_status_ok then return end

local handlers = require 'agr.configs.lsp.handlers'
local utils = require 'agr.core.utils'

mason_lspconfig.setup {
  automatic_installation = true,
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
  flags = {
    debounce_text_changes = 200,
  },
  on_attach = handlers.on_attach,
  root_dir = handlers.root_dir,
}

local config_servers = {
  'jsonls',
  'sumneko_lua',
}

local server_settings = 'agr.configs.lsp.server_settings.'

mason_lspconfig.setup_handlers {
  -- default handler
  function (server_name)
    lspconfig[server_name].setup(opts)

    for _, config_server_name in pairs(config_servers) do
      local server_opts = utils.has_plugin(server_settings .. config_server_name)

      if server_opts then
        lspconfig[config_server_name].setup(vim.tbl_deep_extend('force', server_opts, opts))
      end
    end
  end,

  ['tsserver'] = function ()
    local typescript_status, typescript = pcall(require, 'typescript')
    if not typescript_status then return false end

    typescript.setup {
      server = opts,
    }
  end,

  ['emmet_ls'] = function ()
    lspconfig.emmet_ls.setup(vim.tbl_deep_extend('force', require(server_settings .. 'emmet_ls'), {
      flags = opts.flags,
      root_dir = opts.root_dir,
    }))
  end,
}
