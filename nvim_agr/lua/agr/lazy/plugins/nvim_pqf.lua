local P = {
  'yorickpeterse/nvim-pqf',
  event = 'UIEnter',
  url = 'https://gitlab.com/yorickpeterse/nvim-pqf',
}

P.config = function ()
  local pqf = require('pqf')

  pqf.setup()
end

return P
