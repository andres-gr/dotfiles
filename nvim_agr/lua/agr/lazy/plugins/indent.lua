local I = {
  'Darazaki/indent-o-matic',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
}

I.config = function ()
  local indent = require 'indent-o-matic'

  indent.setup {}
end

return I
