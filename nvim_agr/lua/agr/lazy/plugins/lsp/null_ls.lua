local N = {}

N.setup = function ()
  local null_ls = require 'null-ls'
  local handlers = require 'agr.lazy.plugins.lsp.handlers'

  null_ls.setup {
    debounce = 250,
    on_attach = handlers.on_attach,
    root_dir = handlers.root_dir,
  }
end

return N
