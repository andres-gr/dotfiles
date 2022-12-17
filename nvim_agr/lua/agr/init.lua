local impatient_status_ok, impatient = pcall(require, 'impatient')
if impatient_status_ok then impatient.enable_profile() end

require 'agr.core.base'
require 'agr.core.plugins'
require 'agr.core.autocmds'
require 'agr.core.maps'
require 'agr.core.colorscheme'
