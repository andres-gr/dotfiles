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
  local _window_opts = lsp_windows.default_options

  lsp_windows.default_options = function (opts)
    local options = _window_opts(opts)
    options.border = 'single'
    return options
  end

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(function (_, result, ctx, cfg)
    if result then
      vim.lsp.handlers.hover(_, result, ctx, cfg)
    end
  end, { border = 'rounded' })
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

  if client.name == 'tsserver' or client.name == 'ts_ls' or client.name == 'typescript-tools' then
    client.server_capabilities.document_formatting = nil
  end

  if client.name == 'graphql' then
    client.server_capabilities.hoverProvider = nil
  end

  if client.name == 'tailwindcss' then
    require('telescope').load_extension('tailiscope')
    map('n', '<leader>ft', '<CMD>Telescope tailiscope<CR>', 'Search tailwindcss')
  end

  if client.name == 'eslint' then
    map('n', '\\e', '<CMD>EslintFixAll<CR>', 'LSP fix all eslint')
  end

  -- client.server_capabilities.semanticTokensProvider = nil

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Format lsp command
  pcall(vim.cmd, [[ command! Format execute 'lua vim.lsp.buf.format { async = true }' ]])

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  map('n', 'gf', '<CMD>Lspsaga finder<CR>', 'LSP definition, references')
  map('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>', 'LSP declaration')
  map('n', 'gd', '<CMD>Lspsaga peek_definition<CR>', 'LSP definition')
  map('n', 'K', '<CMD>Lspsaga hover_doc ++silent<CR>', 'LSP hover')
  map('n', 'gh', '<CMD>Lspsaga hover_doc ++silent<CR>', 'LSP hover')
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
  map('n', '\\f', '<CMD>Format<CR>', 'LSP format buffer')
  map('n', '<leader>lsr', '<CMD>LspRestart<CR>', 'LSP restart server')
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
