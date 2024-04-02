local A = {
  'Exafunction/codeium.vim',
  build = ':Codeium Auth',
  cmd = 'Codeium',
  event = 'InsertEnter',
}

A.config = function()
  -- vim.g.codeium_tab_fallback = '<Tab>'

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return {
      expr = true,
      desc = desc,
      silent = true,
    }
  end

  map('i', '<Tab>', function () return vim.fn['codeium#Accept']() end, desc_opts('Codeium accept suggestion'))

  local utils = require 'agr.core.utils'
  local cmp = utils.has_plugin 'cmp'

  if cmp then
    cmp.event:on('menu_opened', function()
      vim.cmd [[ Codeium DisableBuffer ]]
    end)

    cmp.event:on('menu_closed', function()
      vim.cmd [[ Codeium EnableBuffer ]]
    end)
  end
end

return A
