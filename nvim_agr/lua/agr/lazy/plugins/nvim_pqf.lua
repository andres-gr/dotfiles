local P = {
  'yorickpeterse/nvim-pqf',
  event = 'BufReadPre',
}

P.config = function ()
  local pqf = require('pqf')

  pqf.setup()
end

return P
