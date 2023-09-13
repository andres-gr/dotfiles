local utils = require 'agr.core.utils'
local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

local prev_height = vim.opt.cmdheight
local prev_showtabline = vim.opt.showtabline
local prev_status = vim.opt.laststatus

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
    local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
    if stats and stats.type == 'directory' then
      if utils.has_plugin 'neo-tree' then
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

      vim.cmd [[ setlocal nofoldenable ]]

      pcall(del_empty_bufs)

      cmd('BufUnload', {
        callback = function ()
          vim.opt.cmdheight = prev_height
          vim.opt.laststatus = prev_status
          vim.opt.showtabline = prev_showtabline

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

cmd('FileType', {
  callback = function (event)
    local type = vim.api.nvim_buf_get_option(event.buf, 'filetype')

    if type == 'neo-tree' then
      vim.keymap.set('n', '<leader>o', '<C-w>l', {
        buffer = event.buf,
        desc = 'Focus right buffer',
        remap = false,
        silent = true,
      })
    end
  end,
  desc = 'Add neo tree buffer maps',
  group = neotree,
  pattern = 'neo-tree',
})

cmd('User', {
  callback = function (event)
    if utils.has_plugin 'alpha' then
      local fallback_on_empty = is_empty_buf(event.buf)

      if fallback_on_empty then
        vim.cmd [[ Neotree close ]]
        vim.cmd [[ Alpha ]]
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
      if not should_skip then vim.cmd [[ Alpha ]] end
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

cmd('FileType', {
  callback = function (event)
    local type = vim.api.nvim_buf_get_option(event.buf, 'filetype')

    if type == 'qf' then
      vim.keymap.set('n', 'k', '<CMD>cprev<CR>zz<CMD>copen<CR>', {
        buffer = event.buf,
        desc = 'Prev in qflist',
        remap = false,
        silent = true,
      })

      vim.keymap.set('n', 'j', '<CMD>cnext<CR>zz<CMD>copen<CR>', {
        buffer = event.buf,
        desc = 'Next in qflist',
        remap = false,
        silent = true,
      })

      vim.keymap.set('n', 'h', '<CMD>lprev<CR>zz', {
        buffer = event.buf,
        desc = 'Prev in location list',
        remap = false,
        silent = true,
      })

      vim.keymap.set('n', 'l', '<CMD>lnext<CR>zz', {
        buffer = event.buf,
        desc = 'Next in location list',
        remap = false,
        silent = true,
      })
    end
  end,
  desc = 'Add qf buffer maps',
  group = general,
  pattern = 'qf',
})

-- cmd({ 'BufRead', 'BufNewFile' }, {
--   callback = function () vim.diagnostic.disable(0) end,
--   desc = 'Diable LSP on node_modules',
--   group = general,
--   pattern = '*/node_modules/*',
-- })

cmd('WinLeave', {
	callback = function ()
		if vim.bo.ft == 'TelescopePrompt' and vim.fn.mode() == 'i' then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'i', false)
		end
	end,
  group = general,
})

cmd('BufReadPost', {
  callback = function ()
    -- go to last loc when opening a buffer
    local exclude = { 'gitcommit' }
    local buf = vim.api.nvim_get_current_buf()
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  group = general,
})


cmd('QuitPre', {
  callback = function()
    local invalid_win = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match('neo--tree') ~= nil then
        table.insert(invalid_win, w)
      end
    end
    if #invalid_win == #wins - 1 then
      -- Should quit, so we close all invalid windows.
      for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
    end
    -- local tree_wins = {}
    -- local floating_wins = {}
    -- local wins = vim.api.nvim_list_wins()
    -- for _, w in ipairs(wins) do
    --   local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
    --   if bufname:match('neo--tree') ~= nil then
    --     table.insert(tree_wins, w)
    --   end
    --   if vim.api.nvim_win_get_config(w).relative ~= '' then
    --     table.insert(floating_wins, w)
    --   end
    -- end
    -- if 1 == #wins - #floating_wins - #tree_wins then
    --   -- Should quit, so we close all invalid windows.
    --   for _, w in ipairs(tree_wins) do
    --     vim.api.nvim_win_close(w, true)
    --   end
    -- end
  end
})

local agr = augroup('agr_highlights', { clear = true })
cmd({ 'VimEnter', 'ColorScheme' }, {
  callback = function ()
    vim.cmd [[ doautocmd User AGRColorScheme ]]
  end,
  desc = 'Load highlights',
  group = agr,
})
