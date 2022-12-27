local fn = vim.fn

-- Automatically install packer
local lazypath = fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

local lazy_opts = {
  defaults = {
    lazy = true,
    version = '*',
  },
  install = { colorscheme = { 'dracula' } },
}

require 'lazy'.setup('agr.lazy.plugins', lazy_opts)
