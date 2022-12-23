local impatient_status_ok, impatient = pcall(require, 'impatient')
if impatient_status_ok then impatient.enable_profile() end

require 'agr.core.base'
require 'agr.lazy'

vim.api.nvim_create_autocmd('User', {
  callback = function ()
    require 'agr.core.maps'
    require 'agr.core.autocmds'
    require 'agr.core.colorscheme'
  end,
  desc = 'Lazy load autocmds, mappings and colorscheme',
  pattern = 'VeryLazy',
})
