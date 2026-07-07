-- Loads monitors and workspaces configs if available
pcall(require, 'monitors')
pcall(require, 'workspaces')

local require_from_dir = require 'utils.require_from_dir'

-- Loads all configs from directories
require_from_dir 'modules'
require_from_dir 'plugins'

-- Load bundle if available
pcall(require, 'bundle')

-- Load splash if available
pcall(require, 'splash')

-- Loads all apps configs
require_from_dir 'apps'

-- Load performance mode override config last
pcall(require, 'perf_mode')
