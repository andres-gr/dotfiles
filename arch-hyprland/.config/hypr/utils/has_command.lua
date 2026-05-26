--- Checks if a command/binary exists in the system's PATH.
--- This is a pure Lua implementation of the POSIX `command -v`
--- @param cmd string The command name to check (e.g., "rofi", "kitty")
--- @return boolean exists True if the command is available, false otherwise
local has_command = function(cmd)
  -- 'command -v' is the POSIX-compliant way to check for an executable
  local handle = io.popen('command -v ' .. cmd .. ' 2>/dev/null')
  if handle == nil then
    return false
  end

  local result = handle:read('*a')
  handle:close()
  return result ~= ''
end

return has_command
