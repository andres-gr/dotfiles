local N = {
  'jose-elias-alvarez/null-ls.nvim',
}

N.config = function ()
  local null_ls = require 'null-ls'
  local handlers = require 'agr.lazy.plugins.lsp.handlers'

  null_ls.setup {
    debounce = 150,
    on_attach = handlers.on_attach,
    root_dir = handlers.root_dir(),
  }
end

return N
