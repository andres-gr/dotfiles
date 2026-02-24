local N = {}

N.setup = function ()
  local null_ls = require 'null-ls'
  local h = require 'null-ls.helpers'
  local handlers = require 'agr.lazy.plugins.lsp.handlers'

  null_ls.setup {
    debounce = 250,
    on_attach = handlers.on_attach,
    root_dir = handlers.root_dir,
    sources = {
      -- Python formatting (your existing config)
      {
        filetypes = { 'python' },
        generator = h.formatter_factory {
          command = 'blackd-client',
          to_stdin = true,
        },
        method = null_ls.methods.FORMATTING,
        name = 'blackd',
      },

      -- Go formatting
      null_ls.builtins.formatting.goimports.with({
        extra_args = { '-local', 'github.com/andres-gr' }, -- Change this to your module path
      }),
      null_ls.builtins.formatting.gofumpt,

      -- Go linting
      null_ls.builtins.diagnostics.golangci_lint.with({
        -- Only run on save to avoid performance issues
        -- method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
        -- Timeout for golangci-lint
        timeout = 10000,
      }),
    },
  }
end

return N
