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
    update_in_insert = false,
    virtual_text = {
      prefix = '■', -- Could be '●', '▎', 'x', '■', '', '', '■', '◆', '◪', '󰊹'
    },
  }

  vim.diagnostic.config(config)

  local lsp_windows = require 'lspconfig.ui.windows'
  lsp_windows.default_options.border = 'single'

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
  end

  if client.name == 'graphql' then
    client.server_capabilities.hoverProvider = nil
  end

  client.server_capabilities.semanticTokensProvider = nil

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  map('n', 'gf', '<CMD>Lspsaga finder<CR>', 'LSP definition, references')
  map('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>', 'LSP declaration')
  map('n', 'gd', '<CMD>Lspsaga peek_definition<CR>', 'LSP definition')
  map('n', 'K', '<CMD>Lspsaga hover_doc<CR>', 'LSP hover')
  map('n', 'gh', '<CMD>Lspsaga hover_doc<CR>', 'LSP hover')
  map('n', 'gi', '<CMD>lua vim.lsp.buf.implementation()<CR>', 'LSP implementation')
  map('n', '<leader>k', '<CMD>lua vim.lsp.buf.signature_help()<CR>', 'LSP signature help')
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
end

local common_capabilities = function ()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local cmp_status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if cmp_status_ok then
    -- Add additional capabilities supported by nvim-cmp
    -- See: https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

H.capabilities = common_capabilities()
H.root_dir = function () return vim.fn.getcwd() end

return H
