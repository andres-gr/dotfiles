local A = {
  'Exafunction/codeium.vim',
  build = ':Codeium Auth',
  cmd = 'Codeium',
  event = 'InsertEnter',
}

A.config = function ()
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
  map('n', '<M-g>', function () return vim.fn['codeium#Chat']() end, desc_opts('Codeium chat'))

  local utils = require 'agr.core.utils'
  local cmp = utils.has_plugin 'cmp'

  if cmp then
    cmp.event:on('menu_opened', function ()
      vim.b.codeium_render = false
      vim.cmd [[ Codeium DisableBuffer ]]
    end)

    cmp.event:on('menu_closed', function ()
      vim.b.codeium_render = true
      vim.cmd [[ Codeium EnableBuffer ]]
    end)
  end
end

return A
