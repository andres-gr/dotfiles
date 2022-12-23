local E = {}

E.setup = function ()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return {
    capabilities = capabilities,
    filetypes = {
      'css',
      'html',
      'javascriptreact',
      'less',
      'sass',
      'scss',
      'typescriptreact',
    },
  }
end

return E
