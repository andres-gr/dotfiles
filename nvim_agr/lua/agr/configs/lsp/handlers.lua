local H = {}

H.setup = function ()
  local signs = {
    {
      name = 'DiagnosticSignError',
      text = ''
    },
    {
      name = 'DiagnosticSignWarn',
      text = ''
    },
    {
      name = 'DiagnosticSignHint',
      text = ''
    },
    {
      name = 'DiagnosticSignInfo',
      text = ''
    },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
  end

  local config = {
    float = {
      border = 'rounded',
      focusable = false,
      header = '',
      prefix = '',
      source = 'always',
      style = 'minimal',
    },
    severity_sort = true,
    signs = {
      active = signs,
    },
    underline = true,
    update_in_insert = true,
    virtual_text = false,
  }

  vim.diagnostic.config(config)
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
end

local function lsp_highlight_document (client)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    vim.api.nvim_exec([[
    augroup lsp_document_highlight
    autocmd! * <buffer>
    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]], false)
  end
end

local descOpts = function (desc)
  local result = { desc = desc }
  local opts = {
    noremap = true,
    silent = true,
  }

  for key, val in pairs(opts) do
    result[key] = val
  end

  return result
end

H.on_attach = function (client, bufnr)
  local function buf_set_keymap (...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option (...) vim.api.nvim_buf_set_option(bufnr, ...) end

  if client.name == 'tsserver' then
    client.server_capabilities.document_formatting = false
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', descOpts('LSP declaration'))
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', descOpts('LSP definition'))
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', descOpts('LSP hover'))
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', descOpts('LSP implementation'))
  buf_set_keymap('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', descOpts('LSP signature help'))
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', descOpts('LSP add workspace folder'))
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', descOpts('LSP remove workspace folder'))
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', descOpts('LSP list workspace folders'))
  buf_set_keymap('n', '<leader>gd', '<cmd>lua vim.lsp.buf.type_definition()<CR>', descOpts('LSP type definition'))
  buf_set_keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.rename()<CR>', descOpts('LSP rename'))
  buf_set_keymap('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', descOpts('LSP code actions'))
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', descOpts('LSP references'))
  buf_set_keymap('n', 'gl', '<cmd>lua vim.diagnostic.open_float({ scope = "line" })<CR>', descOpts('LSP show line diagnostics'))
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', descOpts('LSP prev diagnostic'))
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', descOpts('LSP next diagnostic'))
  buf_set_keymap('n', 'gq', '<cmd>lua vim.diagnostic.setloclist()<CR>', descOpts('LSP diagnostic set loclist'))
  buf_set_keymap('n', '\\f', '<cmd>lua vim.lsp.buf.formatting()<CR>', descOpts('LSP format'))
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]

  lsp_highlight_document(client)
end

local cmp_status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_status_ok then
  -- Add additional capabilities supported by nvim-cmp
  -- See: https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

  capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    },
  }

  H.capabilities = capabilities
end

H.root_dir = function () return vim.fn.getcwd() end

return H

