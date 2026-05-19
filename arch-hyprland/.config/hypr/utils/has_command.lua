--- Checks if a command/binary exists in the system's PATH.
--- @param cmd string The command name to check (e.g., "rofi", "kitty")
--- @return boolean exists True if the command is available, false otherwise
local has_command = function(cmd)
  -- "command -v" returns exit code 0 if found, non-zero if not.
  -- We redirect stdout and stderr to /dev/null to keep the console clean.
  local success = os.execute("command -v " .. cmd .. " > /dev/null 2>&1") == true
  return success
end

return has_command
