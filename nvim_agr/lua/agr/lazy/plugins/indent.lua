local I = {
  'Darazaki/indent-o-matic',
  event = 'BufReadPost',
}

I.config = function ()
  local indent = require 'indent-o-matic'

  indent.setup {}
end

return I
