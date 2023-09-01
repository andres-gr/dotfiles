local P = {
  'yorickpeterse/nvim-pqf',
  event = 'BufWinEnter',
}

P.config = function ()
  local pqf = require('pqf')

  pqf.setup()
end

return P
