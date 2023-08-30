local S = {
  'kylechui/nvim-surround',
  event = 'BufReadPost',
}

S.config = function ()
  local surround = require 'nvim-surround'

  surround.setup {}
end

return S
