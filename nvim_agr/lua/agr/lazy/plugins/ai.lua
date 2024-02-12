local A = {
  'zbirenbaum/copilot.lua',
  build = ':Copilot auth',
  cmd = 'Copilot',
  event = 'InsertEnter',
}

A.config = function()
  local copilot = require 'copilot'

  copilot.setup {
    panel = {
      auto_refresh = true,
      enabled = true,
    },
    suggestion = {
      accept = false, -- disable builtin keymaps
      auto_trigger = true,
      enabled = true,
    },
  }

  local utils = require 'agr.core.utils'
  local cmp = utils.has_plugin 'cmp'

  if cmp then
    cmp.event:on('menu_opened', function()
      vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on('menu_closed', function()
      vim.b.copilot_suggestion_hidden = false
    end)
  end
end

return A
