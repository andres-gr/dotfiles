local M = {
  'hrsh7th/nvim-cmp',
  branch = 'main',
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    {
      'L3MON4D3/LuaSnip',
      run = 'make install_jsregexp',
    },
    'rafamadriz/friendly-snippets',
    'saadparwaiz1/cmp_luasnip',
  },
  event = 'InsertEnter',
}

-- local function check_codeium ()
--   local status = vim.fn['codeium#GetStatusString']()
--
--   return status ~= ' ON' or status ~= '0'
-- end

M.config = function ()
  local cmp = require 'cmp'
  local types = require 'cmp.types'
  local luasnip = require 'luasnip'
  local lspkind = require 'lspkind'

  luasnip.setup {
    delete_check_events = 'TextChanged',
    history = true,
  }

  require 'luasnip/loaders/from_vscode'.lazy_load {
    paths = {
      '~/.local/share/nvim/lazy/friendly-snippets',
      vim.fn.stdpath('config') .. '/snippets',
    },
  }

  --   פּ ﯟ   some other good icons
  local kind_icons = {
    Class = '  ',
    Color = '  ',
    Constant = '  ',
    Constructor = '  ',
    Enum = '  ',
    EnumMember = '  ',
    Event = '  ',
    Field = '  ',
    File = '  ',
    Folder = '  ',
    Function = '  ',
    Interface = '  ',
    Keyword = '  ',
    Method = '  ',
    Module = '  ',
    Operator = '  ',
    Property = '  ',
    Reference = '  ',
    Snippet = '  ',
    Struct = '  ',
    Text = '  ',
    TypeParameter = '  ',
    Unit = '  ',
    Value = '  ',
    Variable = '  ',
  }

  cmp.setup {
    cmdline = {
      view = {
        entries = {
          name = 'wildmenu',
          separator = '|',
        },
      },
    },
    completion = {
      completeopt = 'menu,menuone,noinsert', -- 'menu,menuone,noinsert,noselect',
      keyword_length = 1,
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    enabled = function ()
      if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
        return false
      end

      return true
    end,
    experimental = {
      ghost_text = false,
      native_menu = false,
    },
    formatting = {
      duplicates = {
        buffer = 1,
        luasnip = 1,
        nvim_lsp = 0,
        path = 1,
      },
      duplicates_default = 0,
      fields = { 'abbr', 'kind', 'menu' },
      format = lspkind.cmp_format({
        ellipsis_char = '...',
        maxwidth = 50,
        menu = {
          nvim_lsp = '[LSP]',
          luasnip = '[Snippet]',
          buffer = '[Buffer]',
          path = '[Path]',
        },
        mode = 'symbol_text',
        symbol_map = kind_icons,
      }),
      max_width = 50,
    },
    mapping = {
      ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		  ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
      ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		  ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-2), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.mapping {
        i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
          else
            fallback()
          end
        end,
      },
      ['<C-e>'] = cmp.mapping {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      },
      ['<M-o>'] = cmp.mapping {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      },
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm { select = true },
      ['<Tab>'] = cmp.mapping(function (fallback)
        if cmp.visible() then
          cmp.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }
        -- elseif check_codeium() then
        --   vim.fn['codeium#Accept']()
        elseif luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function (fallback)
        if cmp.visible() then
          fallback()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    snippet = {
      expand = function (args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    sources = {
      {
        name = 'nvim_lsp',
        entry_filter = function (entry)
          local kind = types.lsp.CompletionItemKind[entry:get_kind()]

          return kind ~= 'Text'
        end,
      },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
    },
    window = {
      ---@diagnostic disable-next-line: undefined-field
      completion = cmp.config.window.bordered {
        winhighlight = 'FloatBorder:CmpNormalCompletionBorder,CursorLine:Visual',
      },
      ---@diagnostic disable-next-line: undefined-field
      documentation = cmp.config.window.bordered {
        winhighlight = 'FloatBorder:CmpNormalDocumentationBorder,CursorLine:Visual',
      },
    },
  }
end

return M
