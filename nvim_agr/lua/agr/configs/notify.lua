local notify_status_ok, notify = pcall(require, 'notify')
if not notify_status_ok then return end

notify.setup {
  background_colour = '#000000',
  stages = 'fade',
}

vim.notify = notify
