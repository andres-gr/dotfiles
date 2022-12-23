local I = {
  'RRethy/vim-illuminate',
  event = 'VeryLazy',
}

I.config = function ()
  local illuminate = require 'illuminate'

  illuminate.configure()
end

return I
