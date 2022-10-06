local dracula_status_ok, dracula = pcall(require, 'dracula')
if not dracula_status_ok then
  vim.notify('dracula theme not installed!')
  return
else
  dracula.setup({
    colors = {
      bg = '#22212C',
      fg = '#F8F8F2',
      selection = '#454158',
      comment = '#7970A9',
      red = '#FF9580',
      orange = '#FFCA80',
      yellow = '#FFFF80',
      green = '#8AFF80',
      purple = '#9580FF',
      cyan = '#80FFEA',
      pink = '#FF80BF',
      bright_red = '#FFBFB3',
      bright_green = '#B9FFB3',
      bright_yellow = '#FFFFB3',
      bright_blue = '#BFB3FF',
      bright_magenta = '#FFB3D9',
      bright_cyan = '#B3FFF2',
      bright_white = '#FFFFFF',
      menu = '#2B2640',
      visual = '#424450',
      gutter_fg = '#4B5263',
      nontext = '#3B4048',
    },
    italic_comment = true,
    transparent_bg = true,
  })
end

local colorscheme = 'dracula'

local color_status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not color_status_ok then
  vim.notify('colorscheme ' .. colorscheme .. ' not found!')
  return
end

