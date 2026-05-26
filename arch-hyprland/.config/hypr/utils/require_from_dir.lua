---Creates a require function that loads modules from a directory
---@param config_sub_dir string
local require_from_dir = function(config_sub_dir)
  -- Expand the user home directory to get the full path
  local home = os.getenv('HOME')
  local full_path = home .. '/.config/hypr/' .. config_sub_dir

  -- Use io.popen to list only .lua files in that directory
  local handle = io.popen('ls ' .. full_path .. '/*.lua 2>/dev/null')

  if handle then
    for file in handle:lines() do
      -- Extract just the filename without the path and without the extension
      local filename = file:match('([^/]+)%.lua$')

      if filename then
        -- Safely require the module (e.g., "configs.keybinds")
        require(config_sub_dir .. '.' .. filename)
      end
    end
    handle:close()
  end
end

return require_from_dir
