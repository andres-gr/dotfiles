-------------------------------
---- BINDS CONFIGURATION ------
-------------------------------

local mod = require 'utils.mod_key'

local apps = {
  browser = 'zen-browser',
  browser_alt = 'chromium',
  btop = 'ghostty -e zsh -c btop',
  explorer = 'dolphin',
  menu = 'fuzzel',
  terminal = '_NO_TMUX=1 ghostty -e zsh',
  terminal_alt = 'kitty',
  yazi = 'ghostty -e zsh -c yazi',
}

local base_path = os.getenv 'XDG_CONFIG_HOME' or os.getenv 'HOME' .. '/.local/bin'

local scripts = {
  close_window = base_path .. '/dont-kill-steam',
  screenshot = base_path .. '/screenshot-tool-agr',
  workspace_clamp = base_path .. '/hypr-workspace-clamp',
}
