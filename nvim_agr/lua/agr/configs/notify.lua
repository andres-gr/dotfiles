local notify_status_ok, notify = pcall(require, 'notify')
if not notify_status_ok then return end

notify.setup {
  background_colour = '#000000',
  max_height = 50,
  max_width = 100,
  stages = 'fade_in_slide_out',
  timeout = 1500,
}

vim.notify = notify

