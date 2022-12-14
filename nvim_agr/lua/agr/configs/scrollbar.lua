local scrollbar_status, scrollbar = pcall(require, 'scrollbar')
if not scrollbar_status then return end

scrollbar.setup {
  excluded_filetypes = {
    'alpha',
    'neo-tree',
    'TelescopePrompt',
  },
  handle = {
    highlight = 'CursorLine',
    text = '',
  },
  handlers = {
    gitsigns = true,
    search = true,
  },
  marks = {
    Search = {
      highlight = 'CmpItemKindConstant',
    },
  },
  throttle_ms = 150,
}
