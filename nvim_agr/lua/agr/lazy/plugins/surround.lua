local S = {
  'kylechui/nvim-surround',
  event = 'VeryLazy',
}

S.config = function ()
  local surround = require 'nvim-surround'

  surround.setup {}
end

return S
