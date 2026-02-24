local I = {
  'RRethy/vim-illuminate',
  event = {
    'BufNewFile',
    'BufReadPost',
  },
}

I.config = function ()
  local illuminate = require 'illuminate'

  illuminate.configure {
    delay = 200,
  }
end

return I
