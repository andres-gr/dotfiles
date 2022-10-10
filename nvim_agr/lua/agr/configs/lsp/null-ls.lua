local nls_status_ok, nls = pcall(require, 'null-ls')
if not nls_status_ok then return end

nls.setup {
  on_attach = require 'agr.configs.lsp.handlers'.on_attach
}

