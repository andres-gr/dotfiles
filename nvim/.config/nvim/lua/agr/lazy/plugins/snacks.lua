local S = {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
}

S.opts = {
  input = {}, -- Enhances `ask()`
  lazygit = {
    configure = true,
    theme = {
      selectedLineBgColor = { bg = 'NeoTreeCursorLine' }
    }
  },
  picker = { -- Enhances `select()`
    actions = {
      opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
    },
    win = {
      input = {
        keys = {
          ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
        },
      },
    },
  },
}

S.keys = {
  ---@diagnostic disable-next-line: undefined-global
  { '<leader>lg', function() Snacks.lazygit() end, desc = 'LazyGit' },
}

return S
