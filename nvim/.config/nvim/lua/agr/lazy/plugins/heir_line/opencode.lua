local O = {}

O.setup = function ()
  local opencode_ok, opencode = pcall(require, 'opencode')

  return {
    condition = function ()
      return opencode_ok
    end,
    provider = function ()
      return opencode.statusline() .. ' '
    end,
  }
end

return O
