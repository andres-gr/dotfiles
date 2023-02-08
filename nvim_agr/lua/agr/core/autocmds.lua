local utils = require 'agr.core.utils'
local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

local prev_height = vim.opt.cmdheight
local prev_showtabline = vim.opt.showtabline
local prev_status = vim.opt.laststatus
local prev_winbar = vim.opt_local.winbar

local is_empty_buf = function (buf)
  local fallback_name = vim.api.nvim_buf_get_name(buf)
  local fallback_ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local fallback_on_empty = fallback_name == '' and fallback_ft == ''

  return fallback_on_empty
end

local del_empty_bufs = function ()
  local bufs_loaded = {}

  for _, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf_hndl) and is_empty_buf(buf_hndl) then
      vim.api.nvim_buf_delete(buf_hndl, {})
    end
  end

  return bufs_loaded
end

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
  callback = function (event)
    local type = vim.api.nvim_buf_get_option(event.buf, 'filetype')

    if type == 'alpha' then
      vim.opt.cmdheight = 0
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
      vim.opt_local.winbar = nil

      vim.cmd [[ setlocal nofoldenable ]]

      pcall(del_empty_bufs)

      cmd('BufUnload', {
        callback = function ()
          vim.opt.cmdheight = prev_height
          vim.opt.laststatus = prev_status
          vim.opt.showtabline = prev_showtabline
          vim.opt_local.winbar = prev_winbar

          pcall(del_empty_bufs)
        end,
        group = alpha_settings,
        pattern = '<buffer>',
      })
    end
  end,
  desc = 'Disable editor features in alpha',
  group = alpha_settings,
  pattern = 'alpha',
})

cmd('User', {
  callback = function (event)
    if utils.has_plugin 'alpha' then
      local fallback_on_empty = is_empty_buf(event.buf)

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

cmd('UIEnter', {
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
      if not should_skip then vim.cmd [[ :Alpha ]] end
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

