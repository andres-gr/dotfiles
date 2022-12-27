local E = {
  'max397574/better-escape.nvim',
  event = 'InsertCharPre',
}

E.config = function ()
  local escape = require 'better_escape'

  escape.setup()
end

return E
