local scrollbar_status, scrollbar = pcall(require, 'scrollbar')
if not scrollbar_status then return end

scrollbar.setup {
  excluded_filetypes = {
    'alpha',
  },
  handlers = {
    gitsigns = true,
    search = true,
  },
  throttle_ms = 150,
}
