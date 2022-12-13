local alpha_status_ok, alpha = pcall(require, 'alpha')
if not alpha_status_ok then return end

require 'alpha.term'

local dash = require 'alpha.themes.dashboard'

local btn = function (sc, txt, keybind, opts)
  local b = dash.button(sc, txt, keybind, opts)
  b.opts.hl = 'AlphaButtonText'
  b.opts.hl_shortcut = 'AlphaButtonShortcut'
  return b
end

-- Terminal header w/lolcat
dash.section.terminal.command = 'cat | lolcat ' .. os.getenv('HOME') .. '/devel/dotfiles/assets/banner.cat'
dash.section.terminal.height = 14
dash.section.terminal.width = 78
dash.section.terminal.opts = {
  redraw = true,
}

-- Dash buttons group
dash.section.buttons.val = {
  btn('o', '   Recently used files', ':Telescope oldfiles<CR>'),
  btn('f', '   Search files', ':lua require("telescope.builtin").find_files()<CR>'),
  btn('F', '   Search all files', ':lua require("telescope.builtin").find_files({hidden = true, no_ignore = true})<CR>'),
  btn('n', '   New file', ':ene <BAR> startinsert <CR>'),
  btn('s', '   Sync plugins', ':PackerSync<CR>'), -- Packer sync
  btn('u', 'ﮮ   Update plugins', ':PackerUpdate<CR>'), -- Packer update
  btn('q', '   Quit Neovim', ':qa!<CR>'),
}

dash.section.buttons.opts = {
  spacing = 1,
}

-- Footer
local function footer()
  -- local total_plugins = #vim.tbl_keys(packer_plugins)
  local version = vim.version()
  local nvim_version_info = '  Neovim v' .. version.major .. '.' .. version.minor .. '.' .. version.patch

  -- return ' ' .. total_plugins .. ' plugins' .. nvim_version_info
  return nvim_version_info
end

dash.section.footer.val = footer()
dash.section.footer.opts.hl = 'AlphaFooter'

alpha.setup {
  layout = {
    {
      type = 'padding',
      val = 8,
    },
    dash.section.terminal,
    {
      type = 'padding',
      val = 18,
    },
    dash.section.buttons,
    {
      type = 'padding',
      val = 10,
    },
    dash.section.footer,
  },
}

