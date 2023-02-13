local M = {}

M.setup = function ()
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
      'lua_ls',
      'tsserver',
      'vimls',
      'yamlls',
    },
  }

  handlers.setup()

  local default_opts = {
    capabilities = handlers.capabilities,
    flags = {
      debounce_text_changes = 200,
    },
    on_attach = handlers.on_attach,
    root_dir = handlers.root_dir,
  }

  local config_servers = {
    ['jsonls'] = true,
    ['lua_ls'] = true,
  }

  local server_settings_path = 'agr.lazy.plugins.lsp.server_settings.'

  mason_lspconfig.setup_handlers {
    -- default handler
    function (server_name)
      local opts = default_opts

      if utils.contains(config_servers, server_name) then
        local server_opts = utils.has_plugin(server_settings_path .. server_name).setup()

        if server_opts then
          opts = vim.tbl_deep_extend('force', default_opts, server_opts)
        end
      end

      lspconfig[server_name].setup(opts)
    end,

    ['tsserver'] = function ()
      local typescript = require 'typescript'

      typescript.setup {
        server = vim.tbl_deep_extend('force', default_opts, {
          autostart = true,
          init_options = {
            tsserver = {
              path = '/Users/andres/Library/pnpm/global/5/.pnpm/typescript@4.9.5/node_modules/typescript/lib',
            },
          },
        }),
      }
    end,
  }
end

return M
