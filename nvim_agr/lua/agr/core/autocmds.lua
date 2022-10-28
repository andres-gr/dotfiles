local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

augroup('neotree_start', { clear = true })
cmd('BufEnter', {
  callback = function ()
    local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
    if stats and stats.type == 'directory' then
      require 'neo-tree.setup.netrw'.hijack()
    end
  end,
  desc = 'Open Neo-Tree on startup with directory',
  group = 'neotree_start',
})

augroup('alpha_settings', { clear = true })
cmd('FileType', {
  callback = function ()
    local prev_showtabline = vim.opt.showtabline
    vim.opt.showtabline = 0
    vim.opt_local.winbar = nil
    cmd('BufUnload', {
      callback = function () vim.opt.showtabline = prev_showtabline end,
      pattern = '<buffer>',
    })
  end,
  desc = 'Disable tabline for alpha',
  group = 'alpha_settings',
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
  group = 'alpha_settings',
  pattern = 'alpha',
})

cmd('FileType', {
  callback = function ()
    vim.cmd [[ setlocal nofoldenable ]]
  end,
  desc = 'Disable fold for alpha',
  group = 'alpha_settings',
  pattern = 'alpha',
})

cmd('User', {
  callback = function (event)
    local fallback_name = vim.api.nvim_buf_get_name(event.buf)
    local fallback_ft = vim.api.nvim_buf_get_option(event.buf, 'filetype')
    local fallback_on_empty = fallback_name == '' and fallback_ft == ''

    if fallback_on_empty then
      require 'neo-tree'.close_all()
      vim.cmd [[ :Alpha ]]
    end
  end,
  desc = 'Go to dash if no open files',
  group = 'alpha_settings',
  pattern = 'BDeletePost*',
})

cmd('VimEnter', {
  callback = function ()
    -- optimized start check from https://github.com/goolord/alpha-nvim
    local alpha_avail, alpha = pcall(require, 'alpha')
    if alpha_avail then
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
  group = 'alpha_settings',
})

augroup('_general_settings', { clear = true })
cmd('TextYankPost', {
  callback = function ()
    require 'vim.highlight'.on_yank {
      higroup = 'Search',
      timeout = 200,
    }
  end,
  desc = 'Highlight text on yank',
  group = '_general_settings',
  pattern = '*',
})

