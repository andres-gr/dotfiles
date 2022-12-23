local M = {
  'williamboman/mason-lspconfig.nvim',
}

M.config = function ()
  local mason_lspconfig = require 'mason-lspconfig'
  local lspconfig = require 'lspconfig'
  local handlers = require 'agr.lazy.plugins.lsp.handlers'
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

  local server_settings = 'agr.lazy.plugins.lsp.server_settings.'

  mason_lspconfig.setup_handlers {
    -- default handler
    function (server_name)
      lspconfig[server_name].setup(opts)

      for _, config_server_name in pairs(config_servers) do
        local server_opts = utils.has_plugin(server_settings .. config_server_name).setup()

        if server_opts then
          lspconfig[config_server_name].setup(vim.tbl_deep_extend('force', server_opts, opts))
        end
      end
    end,

    ['tsserver'] = function ()
      local typescript = require 'typescript'

      typescript.setup {
        server = opts,
      }
    end,

    ['emmet_ls'] = function ()
      lspconfig.emmet_ls.setup(vim.tbl_deep_extend('force', require(server_settings .. 'emmet_ls').setup(), {
        flags = opts.flags,
        root_dir = opts.root_dir,
      }))
    end,
  }
end

return M
