local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then return end

local snip_status_ok, luasnip = pcall(require, 'luasnip')
if not snip_status_ok then return end

require 'luasnip/loaders/from_vscode'.lazy_load()

local check_backspace = function ()
  -- lunarvim style
  -- local col = vim.fn.col '.' - 1
  -- return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s'

  -- astronvim style
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

--   פּ ﯟ   some other good icons
local kind_icons = {
  Class = '',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Keyword = '',
  Method = 'm',
  Module = '',
  Operator = '',
  Property = '',
  Reference = '',
  Snippet = '',
  Struct = '',
  Text = '',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
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
    ghost_text = true,
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
    format = function (entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({
        nvim_lsp = '(LSP)',
        luasnip = '(Snippet)',
        buffer = '(Buffer)',
        path = '(Path)',
      })[entry.source.name]
      return vim_item
    end,
    max_width = 0,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
		['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
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
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function (fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, { 'i', 's', }),
    ['<S-Tab>'] = cmp.mapping(function (fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's', }),
  },
  snippet = {
    expand = function (args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
}

