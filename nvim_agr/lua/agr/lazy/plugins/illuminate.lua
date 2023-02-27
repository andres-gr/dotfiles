local I = {
  'RRethy/vim-illuminate',
  event = {
    'BufReadPost',
    'BufNewFile',
  },
}

I.config = function ()
  local illuminate = require 'illuminate'

  illuminate.configure {
    delay = 200,
  }
end

return I
