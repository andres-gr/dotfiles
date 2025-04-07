local M = {}

M.setup = function ()
  local mason_lspconfig = require 'mason-lspconfig'
  local lspconfig = require 'lspconfig'
  local handlers = require 'agr.lazy.plugins.lsp.handlers'
  local utils = require 'agr.core.utils'
  local root = lspconfig.util.root_pattern

  mason_lspconfig.setup {
    automatic_installation = true,
    ensure_installed = {
      'bashls',
      'cssls',
      'eslint',
      'graphql',
      'html',
      'jsonls',
      'lua_ls',
      -- 'ts_ls',
      'vimls',
      'yamlls',
    },
  }

  handlers.setup()

  local default_opts = {
    capabilities = handlers.capabilities,
    flags = {
      debounce_text_changes = 250,
    },
    on_attach = handlers.on_attach,
    root_dir = handlers.root_dir,
  }

  local config_servers = {
    ['jsonls'] = true,
    ['lua_ls'] = true,
  }

  local eslint_dirs = {
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    '.eslintrc.json',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    'eslint.config.mts',
    'eslint.config.cts',
  }

  local server_settings_path = 'agr.lazy.plugins.lsp.server_settings.'
  local home_dir = os.getenv 'HOME'

  mason_lspconfig.setup_handlers {
    -- default handler
    function (server_name)
      if server_name == 'tsserver' or server_name == 'ts_ls' then return end

      local opts = default_opts

      if utils.contains(config_servers, server_name) then
        ---@diagnostic disable-next-line: undefined-field
        local server_opts = utils.has_plugin(server_settings_path .. server_name).setup()

        if server_opts then
          opts = vim.tbl_deep_extend('force', default_opts, server_opts)
        end
      end

      if server_name == 'tailwindcss' then
        opts = vim.tbl_deep_extend('force', default_opts, {
          root_dir = function (...)
            return root 'tailwind.config.js'(...)
          end,
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
				          'tw="([^"]*)',
				          'tw={"([^"}]*)',
				          "tw\\.\\w+`([^`]*)",
				          "tw\\(.*?\\)`([^`]*)",
				          '\\/\\*\\ tw\\ \\*\\/"([^"]*)',
				          '\\/\\*\\ tw\\ \\*\\/\\ "([^"]*)',
				          '\\/\\*\\ tw\\ \\*\\/\'([^\']*)',
				          '\\/\\*\\ tw\\ \\*\\/\\ \'([^\']*)',
				          '\\/\\*\\ tw\\ \\*\\/`([^`]*)',
				          '\\/\\*\\ tw\\ \\*\\/\\ `([^`]*)',
                },
              },
            },
          },
        })
      end

      if server_name == 'graphql' then
        opts = vim.tbl_deep_extend('force', default_opts, {
          root_dir = function (...)
            return root ('.graphqlrc*', '.graphql.config.*', 'graphql.config.*')(...)
          end,
        })
      end

      if server_name == 'cssls' then
        opts = vim.tbl_deep_extend('force', default_opts, {
          settings = {
            css = {
              lint = {
                unknownAtRules = 'ignore',
              },
            },
          },
        })
      end

      if server_name == 'eslint' then
        opts = vim.tbl_deep_extend('force', default_opts, {
          root_dir = function (...)
            return root(unpack(eslint_dirs))(...)
          end,
        })
      end

      lspconfig[server_name].setup(opts)
    end,
  }

  local tools = require 'typescript-tools'

  tools.setup(vim.tbl_deep_extend('force', default_opts, {
    root_dir = function (...)
      return root('tsconfig.json', 'jsconfig.json')(...)
    end,
    single_file_support = false,
    settings = {
      -- tsserver_path = home_dir .. '/.bun/install/global/node_modules/typescript/lib/tsserver.js',
      tsserver_plugins = {
        '@styled/typescript-styled-plugin',
        'typescript-styled-plugin', -- before v4.9
      },
    },
  }))
end

return M
