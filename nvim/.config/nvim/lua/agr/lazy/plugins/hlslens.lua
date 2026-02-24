local H = {
  'kevinhwang91/nvim-hlslens',
  event = 'BufReadPost',
}

H.config = function ()
  local scrollbar = require 'scrollbar.handlers.search'

  scrollbar.setup()
end

return H
