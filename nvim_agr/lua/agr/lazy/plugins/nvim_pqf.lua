local P = {
  'yorickpeterse/nvim-pqf',
  event = 'UIEnter',
}

P.config = function ()
  local pqf = require('pqf')

  pqf.setup()
end

return P
