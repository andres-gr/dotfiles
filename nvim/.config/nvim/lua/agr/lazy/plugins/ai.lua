local A = {
  'github/copilot.vim',
  cmd = 'Copilot',
  event = 'VeryLazy',
  version = false,
}

-- must run before the plugin loads, so it lives in init instead of config
A.init = function ()
  vim.g.copilot_no_tab_map = true
end

A.config = function ()
  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local expr_opts = function (desc)
    return {
      desc = desc,
      silent = true,
      expr = true,
      replace_keycodes = false,
    }
  end

  -- <Tab> accept lives in cmp.lua, it is not mapped here.
  -- Empty fallback: returns '' when there is no suggestion, so nothing is inserted.
  map('i', '<C-\\>', 'copilot#Accept("")', expr_opts('Copilot accept suggestion'))
  map('i', '<M-\\>', 'copilot#Accept("")', expr_opts('Copilot accept suggestion'))

  -- cycle when a suggestion is shown, otherwise ask Copilot for one right away
  -- while the cmp menu is open Copilot is suspended by cmp.lua, so stay quiet there
  local cycle_or_suggest = function (cycle)
    if vim.fn.pumvisible() == 1 or vim.fn['copilot#Enabled']() == 0 then return end

    local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()

    if suggestion.text ~= '' then
      vim.fn['copilot#' .. cycle]()
    else
      vim.fn['copilot#Suggest']()
    end
  end

  map('i', '<M-]>', function () cycle_or_suggest('Next') end,
    { desc = 'Copilot next suggestion or summon one' })
  map('i', '<M-[>', function () cycle_or_suggest('Previous') end,
    { desc = 'Copilot previous suggestion or summon one' })

  -- word/line accept keys skipped for now: <C-k> and <C-l> have other binds
end

return A
