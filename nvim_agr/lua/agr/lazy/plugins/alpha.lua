local A = {
  'goolord/alpha-nvim',
  cmd = 'Alpha',
}

A.config = function ()
  local alpha = require 'alpha'

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
  dash.section.terminal.height = 20
  dash.section.terminal.width = 78
  dash.section.terminal.opts = {
    redraw = true,
  }

  -- Dash buttons group
  dash.section.buttons.val = {
    btn('o', '󰈞   Recently used files', ':Telescope oldfiles<CR>'),
    btn('f', '󰱼   Search files', ':Telescope find_files<CR>'),
    btn('F', '󰡦   Search all files', ':lua require("telescope.builtin").find_files({ no_ignore = true })<CR>'),
    btn('w', '󱎸   Search words', ':Telescope live_grep<CR>'),
    btn('g', '   Search git status files', ':Telescope git_status<CR>'),
    btn('n', '   New file', ':ene <BAR> startinsert <CR>'),
    btn('s', '   Show Lazy plugins', ':Lazy<CR>'), -- Show lazy plugin manager
    btn('c', '󰚰   Check plugins', ':Lazy check<CR>'), -- Check lazy plugins update
    btn('q', '󰗼   Quit Neovim', ':qa!<CR>'),
  }

  dash.section.buttons.opts = {
    spacing = 1,
  }

  -- Footer
  local function footer()
    local total_plugins = require 'lazy'.stats().count
    local version = vim.version()
    local nvim_version_info = ' Neovim v' .. version.major .. '.' .. version.minor .. '.' .. version.patch

    return ' ' .. total_plugins .. ' plugins on ' .. nvim_version_info
  end

  dash.section.footer.val = footer()
  dash.section.footer.opts.hl = 'AlphaFooter'

  alpha.setup {
    layout = {
      dash.section.terminal,
      {
        type = 'padding',
        val = 10,
      },
      dash.section.buttons,
      {
        type = 'padding',
        val = 10,
      },
      dash.section.footer,
    },
  }
end

return A
