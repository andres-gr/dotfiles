local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

augroup('neotree_start', { clear = true })
cmd('BufEnter', {
  callback = function ()
    local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
    if stats and stats.type == 'directory' then
      require('neo-tree.setup.netrw').hijack()
    end
  end,
  desc = 'Open Neo-Tree on startup with directory',
  group = 'neotree_start',
})

