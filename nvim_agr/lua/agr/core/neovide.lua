local opts = {
  guifont = { 'MonoLisa Nerd Font', ':h13' },
  neovide_cursor_animation_length = 0.1,
  neovide_cursor_antialiasing = true,
  neovide_cursor_trail_size = 0.9,
  neovide_cursor_vfx_mode = 'railgun',
  neovide_input_use_logo = true,
  neovide_refresh_rate_idle = 10,
  neovide_remember_window_size = true,
  neovide_scale_factor = 1.0,
  neovide_scroll_animation_length = 0.5,
  transparency = 0.9,
}

for key, val in ipairs(opts) do
  vim.opt[key] = val
end

