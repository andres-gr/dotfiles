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
      {
        filetypes = { 'python' },
        generator = h.formatter_factory {
          command = 'blackd-client',
          to_stdin = true,
        },
        method = null_ls.methods.FORMATTING,
        name = 'blackd',
      },
    },
  }
end

return N
