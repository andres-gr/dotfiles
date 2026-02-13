-- Go Utilities Plugin
-- Provides additional Go-specific functionality
-- Place this file in: home/.config/nvim/lua/agr/lazy/plugins/go_utils.lua

local G = {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
}

G.config = function()
  local go = require('go')

  go.setup({
    -- Disable features that conflict with your existing setup
    lsp_cfg = false,  -- Don't use go.nvim's LSP config (you have your own)
    lsp_keymaps = false,  -- Don't set LSP keymaps (you have your own)
    dap_debug = false,  -- Don't configure DAP (you have dap-go)

    -- Enable useful features
    lsp_inlay_hints = {
      enable = true,
      only_current_line = false,
      show_variable_name = true,
      parameter_hints_prefix = "󰊕 ",
      show_parameter_hints = true,
      other_hints_prefix = "=> ",
      max_len_align = false,
      max_len_align_padding = 1,
      right_align = false,
      right_align_padding = 7,
      highlight = "Comment",
    },

    -- Diagnostic settings
    diagnostic = {
      hdlr = false,  -- Don't override diagnostic handler
      underline = true,
      virtual_text = { spacing = 0, prefix = '■' },
      signs = true,
      update_in_insert = false,
    },

    -- Code lens
    lsp_codelens = true,

    -- Formatter settings
    lsp_document_formatting = false,  -- Use conform.nvim instead

    -- Go tags
    gopls_cmd = nil,  -- Use Mason-installed gopls
    gopls_remote_auto = true,

    -- Fill struct
    fillstruct = 'gopls',

    -- Code actions
    lsp_on_attach = nil,  -- Use your own on_attach

    -- Icons
    icons = { breakpoint = '🧘', currentpos = '🏃' },

    -- Test settings
    test_runner = 'go',  -- or 'richgo', 'dlv', 'ginkgo'
    run_in_floaterm = false,

    -- Trouble integration
    trouble = true,

    -- Luasnip integration
    luasnip = true,
  })

  -- Keymaps for Go utilities
  local keymap = require('agr.core.utils').keymap
  local map = keymap.map

  -- Go specific commands
  map('n', '<leader>gf', '<cmd>GoFillStruct<cr>', { desc = 'Go: Fill struct' })
  map('n', '<leader>gi', '<cmd>GoImpl<cr>', { desc = 'Go: Implement interface' })
  map('n', '<leader>gt', '<cmd>GoAddTag<cr>', { desc = 'Go: Add tags to struct' })
  map('n', '<leader>gT', '<cmd>GoRmTag<cr>', { desc = 'Go: Remove tags from struct' })
  map('n', '<leader>gc', '<cmd>GoCmt<cr>', { desc = 'Go: Generate comment' })
  map('n', '<leader>ge', '<cmd>GoIfErr<cr>', { desc = 'Go: Add if err' })
  map('n', '<leader>gx', '<cmd>GoFixImports<cr>', { desc = 'Go: Fix imports' })

  -- Test commands
  map('n', '<leader>tr', '<cmd>GoTest<cr>', { desc = 'Go: Run tests' })
  map('n', '<leader>tf', '<cmd>GoTestFunc<cr>', { desc = 'Go: Test function' })
  map('n', '<leader>tF', '<cmd>GoTestFile<cr>', { desc = 'Go: Test file' })
  map('n', '<leader>tp', '<cmd>GoTestPkg<cr>', { desc = 'Go: Test package' })
  map('n', '<leader>tc', '<cmd>GoCoverage<cr>', { desc = 'Go: Coverage' })
  map('n', '<leader>tC', '<cmd>GoCoverageToggle<cr>', { desc = 'Go: Toggle coverage' })

  -- Code navigation
  map('n', '<leader>ga', '<cmd>GoAlt<cr>', { desc = 'Go: Alternate file (test/impl)' })
  map('n', '<leader>gv', '<cmd>GoAltV<cr>', { desc = 'Go: Alternate in vsplit' })
  map('n', '<leader>gs', '<cmd>GoAltS<cr>', { desc = 'Go: Alternate in split' })

  -- Auto commands for Go files
  local go_augroup = vim.api.nvim_create_augroup('GoCustom', { clear = true })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = go_augroup,
    pattern = '*.go',
    callback = function()
      -- Organize imports before save using code action
      local params = {
        textDocument = vim.lsp.util.make_text_document_params(0),
        range = {
          start = { line = 0, character = 0 },
          ['end'] = { line = vim.fn.line('$'), character = 0 }
        },
        context = { only = { 'source.organizeImports' } }
      }

      local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
      if not result or vim.tbl_isempty(result) then
        return
      end

      for client_id, res in pairs(result) do
        if res.result then
          for _, action in pairs(res.result) do
            -- Execute the code action
            if action.edit then
              local client = vim.lsp.get_client_by_id(client_id)
              local offset_encoding = client and client.offset_encoding or 'utf-16'
              vim.lsp.util.apply_workspace_edit(action.edit, offset_encoding)
            elseif action.command then
              local command = type(action.command) == 'table' and action.command or action
              vim.lsp.buf.execute_command(command)
            end
          end
        end
      end
    end,
  })
end

return G
