local H = {}

H.setup = function ()
  local signs = require 'agr.core.utils'.diagnostics_signs

  local float = {
    border = 'rounded',
    focusable = false,
    format = function (d)
      local code = d.code or (d.user_data and d.user_data.lsp.code)

      if code then
        return string.format('%s [%s]', d.message, code):gsub('1. ', '')
      end

      return d.message
    end,
    header = '',
    prefix = '',
    source = 'always',
    style = 'minimal',
  }

  local config = {
    float = float,
    severity_sort = true,
    signs = {
      active = signs,
    },
    underline = true,
    update_in_insert = true,
    virtual_text = true,
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
end

H.on_attach = function (client, bufnr)
  local keymap = require 'agr.core.utils'.keymap
  local set = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc, bufnr)
  end

  local map = function (m, lhs, rhs, desc)
    set(m, lhs, rhs, desc_opts(desc))
  end

  local function buf_set_option (...) vim.api.nvim_buf_set_option(bufnr, ...) end

  if client.name == 'tsserver' then
    client.server_capabilities.document_formatting = nil
    -- map('n', '<leader>gf', '<CMD>TypescriptRenameFile<CR>', 'LSP TS rename file')
    -- map('n', '<leader>go', '<CMD>TypescriptOrganizeImports<CR>', 'LSP TS organize imports')
    -- map('n', '<leader>gu', '<CMD>TypescriptRemoveUnused<CR>', 'LSP TS remove unused vars')
  end

  if client.name == 'graphql' then
    client.server_capabilities.hoverProvider = nil
  end

  client.server_capabilities.semanticTokensProvider = nil

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- local hover_doc = '<CMD>lua require "agr.core.utils".fix_float_ui("Lspsaga hover_doc")<CR>'
  -- local cursor_diagnostics = '<CMD>lua require "agr.core.utils".fix_float_ui("Lspsaga show_cursor_diagnostics")<CR>'
  -- local line_diagnostics = '<CMD>lua require "agr.core.utils".fix_float_ui("Lspsaga show_line_diagnostics")<CR>'

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  map('n', 'gf', '<CMD>Lspsaga lsp_finder<CR>', 'LSP definition, references')
  map('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>', 'LSP declaration')
  map('n', 'gd', '<CMD>Lspsaga peek_definition<CR>', 'LSP definition')
  map('n', 'K', '<CMD>Lspsaga hover_doc<CR>', 'LSP hover')
  map('n', 'gh', '<CMD>Lspsaga hover_doc<CR>', 'LSP hover')
  map('n', 'gi', '<CMD>lua vim.lsp.buf.implementation()<CR>', 'LSP implementation')
  map('n', '<leader>k', '<CMD>lua vim.lsp.buf.signature_help()<CR>', 'LSP signature help')
  -- map('n', '<leader>wa', '<CMD>lua vim.lsp.buf.add_workspace_folder()<CR>', 'LSP add workspace folder')
  -- map('n', '<leader>wr', '<CMD>lua vim.lsp.buf.remove_workspace_folder()<CR>', 'LSP remove workspace folder')
  -- map('n', '<leader>wl', '<CMD>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', 'LSP list workspace folders')
  map('n', '<leader>gd', '<CMD>lua vim.lsp.buf.type_definition()<CR>', 'LSP type definition')
  map('n', '<leader>gr', '<CMD>Lspsaga rename<CR>', 'LSP rename')
  map('n', '<leader>.', '<CMD>Lspsaga code_action<CR>', 'LSP code actions')
  map('n', 'gr', '<CMD>lua vim.lsp.buf.references()<CR>', 'LSP references')
  map('n', 'gl', '<CMD>Lspsaga show_cursor_diagnostics<CR>', 'LSP show cursor diagnostics')
  map('n', 'gl', '<CMD>Lspsaga show_line_diagnostics<CR>', 'LSP show line diagnostics')
  map('n', '[d', '<CMD>Lspsaga diagnostic_jump_prev<CR>', 'LSP prev diagnostic')
  map('n', ']d', '<CMD>Lspsaga diagnostic_jump_next<CR>', 'LSP next diagnostic')
  map('n', 'gq', '<CMD>lua vim.diagnostic.setloclist()<CR>', 'LSP diagnostic set loclist')
  map('n', '\\f', '<CMD>lua vim.lsp.buf.format { async = true }<CR>', 'LSP format')
  map('n', '<leader>lsr', '<CMD>LspRestart<CR>', 'LSP restart server')

  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.format { async = true }' ]]

  -- lsp_highlight_document(client)
end

local common_capabilities = function ()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local cmp_status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if cmp_status_ok then
    -- Add additional capabilities supported by nvim-cmp
    -- See: https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  -- capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  -- capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  -- capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
  -- capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  -- capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  -- capabilities.textDocument.completion.completionItem.preselectSupport = true
  -- capabilities.textDocument.completion.completionItem.resolveSupport = {
  --   properties = {
  --     'documentation',
  --     'detail',
  --     'additionalTextEdits',
  --   },
  -- }
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true
  -- capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }

  return capabilities
end

H.capabilities = common_capabilities()
H.root_dir = function () return vim.fn.getcwd() end

return H
