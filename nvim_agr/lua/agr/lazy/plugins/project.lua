local P = {
  'ahmedkhalf/project.nvim',
  event = 'BufWinEnter',
}

P.config = function ()
  local project = require 'project_nvim'

  project.setup()
end

return P
