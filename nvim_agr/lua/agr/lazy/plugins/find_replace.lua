local S = {
  'windwp/nvim-spectre',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
}

S.config = function ()
  local spectre = require 'spectre'

  spectre.setup()
end

return S
