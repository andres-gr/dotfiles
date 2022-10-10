local dracula_status_ok, dracula = pcall(require, 'dracula')
if not dracula_status_ok then
  vim.notify('dracula theme not installed!')
  return
end

local colors = require 'agr.core.colors'.dracula_colors

dracula.setup({
  colors = colors,
  italic_comment = true,
  -- overrides = {},
  transparent_bg = true,
})

local colorscheme = 'dracula'

local color_status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not color_status_ok then
  vim.notify('colorscheme ' .. colorscheme .. ' not found!')
  return
end

vim.api.nvim_set_hl(0, 'AlphaButtonText', {
  fg = colors.bright_blue,
})
vim.api.nvim_set_hl(0, 'AlphaButtonShortcut', {
  fg = colors.green,
  bold = true,
})
vim.api.nvim_set_hl(0, 'AlphaFooter', {
  fg = colors.bright_cyan,
})

