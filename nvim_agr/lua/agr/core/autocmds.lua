local utils = require 'agr.core.utils'
local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local neotree = augroup('neotree_start', { clear = true })
cmd('BufEnter', {
  callback = function ()
    if utils.has_plugin 'neo-tree' then
      local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
      if stats and stats.type == 'directory' then
        require 'neo-tree.setup.netrw'.hijack()
      end
    end
  end,
  desc = 'Open Neo-Tree on startup with directory',
  group = neotree,
})

local alpha_settings = augroup('alpha_settings', { clear = true })
cmd('FileType', {
  callback = function ()
    local prev_showtabline = vim.opt.showtabline
    local prev_winbar = vim.opt_local.winbar
    vim.opt.showtabline = 0
    vim.opt_local.winbar = nil
    cmd('BufUnload', {
      callback = function ()
        vim.opt.showtabline = prev_showtabline
        vim.opt_local.winbar = prev_winbar
      end,
      pattern = '<buffer>',
    })
  end,
  desc = 'Disable tabline for alpha',
  group = alpha_settings,
  pattern = 'alpha',
})

cmd('FileType', {
  callback = function ()
    local prev_height = vim.opt.cmdheight
    local prev_status = vim.opt.laststatus
    vim.opt.cmdheight = 0
    vim.opt.laststatus = 0
    cmd('BufUnload', {
      callback = function ()
        vim.opt.cmdheight = prev_height
        vim.opt.laststatus = prev_status
      end,
      pattern = '<buffer>',
    })
  end,
  desc = 'Disable statusline for alpha',
  group = alpha_settings,
  pattern = 'alpha',
})

cmd('FileType', {
  callback = function ()
    vim.cmd [[ setlocal nofoldenable ]]
  end,
  desc = 'Disable fold for alpha',
  group = alpha_settings,
  pattern = 'alpha',
})

cmd('User', {
  callback = function (event)
    if utils.has_plugin 'alpha' then
      local fallback_name = vim.api.nvim_buf_get_name(event.buf)
      local fallback_ft = vim.api.nvim_buf_get_option(event.buf, 'filetype')
      local fallback_on_empty = fallback_name == '' and fallback_ft == ''

      if fallback_on_empty then
        require 'neo-tree'.close_all()
        vim.cmd [[ :Alpha ]]
      end
    end
  end,
  desc = 'Go to dash if no open files',
  group = alpha_settings,
  pattern = 'BDeletePost*',
})

cmd('VimEnter', {
  callback = function ()
    -- optimized start check from https://github.com/goolord/alpha-nvim
    local alpha =  utils.has_plugin 'alpha'
    if alpha then
      local should_skip = false
      if vim.fn.argc() > 0 or vim.fn.line2byte '$' ~= -1 or not vim.o.modifiable then
        should_skip = true
      else
        for _, arg in pairs(vim.v.argv) do
          if arg == '-b' or arg == '-c' or vim.startswith(arg, '+') or arg == '-S' then
            should_skip = true
            break
          end
        end
      end
      if not should_skip then alpha.start(true) end
    end
  end,
  desc = 'Start Alpha when vim is opened with no arguments',
  group = alpha_settings,
})

local general = augroup('_general_settings', { clear = true })
cmd('TextYankPost', {
  callback = function ()
    require 'vim.highlight'.on_yank {
      higroup = 'Search',
      timeout = 200,
    }
  end,
  desc = 'Highlight text on yank',
  group = general,
  pattern = '*',
})

cmd({ 'BufRead', 'BufNewFile' }, {
  callback = function () vim.diagnostic.disable(0) end,
  desc = 'Diable LSP on node_modules',
  group = general,
  pattern = '*/node_modules/*',
})

local agr = augroup('agr_highlights', { clear = true })
cmd({ 'VimEnter', 'ColorScheme' }, {
  callback = function ()
    vim.cmd [[ doautocmd User AGRColorScheme ]]
  end,
  desc = 'Load highlights',
  group = agr,
})

