local O = {
  'nickjvandyke/opencode.nvim',
  dependencies = {
    'folke/snacks.nvim',
    optional = true,
  },
  version = '*',
}

O.config = function()
  -- Dynamically update theme env var before each toggle
  -- This ensures the theme matches vim.o.background at the time opencode is opened
  local original_toggle = require('opencode').toggle
  require('opencode').toggle = function(...)
    ---@module 'opencode.provider.snacks'
    local provider = require('opencode.config').provider
    if provider and provider.opts then
      provider.opts.env = provider.opts.env or {}
      provider.opts.env.OPENCODE_CONFIG_CONTENT = vim.json.encode { theme = 'dracula' }
    end
    return original_toggle(...)
  end

  vim.o.autoread = true -- Required for `opts.events.reload`

  -- Recommended/example keymaps
  vim.keymap.set({ "n", "x" }, "<M-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
    { desc = "Ask opencode…" })
  vim.keymap.set({ "n", "x" }, "<M-x>", function() require("opencode").select() end,
    { desc = "Execute opencode action…" })
  vim.keymap.set({ "n", "t" }, "<M-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

  vim.keymap.set({ "n", "x" }, "<leader>go", function() return require("opencode").operator("@this ") end,
    { desc = "Add range to opencode", expr = true })
  vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
    { desc = "Add line to opencode", expr = true })

  vim.keymap.set("n", "<M-u>", function() require("opencode").command("session.half.page.up") end,
    { desc = "Scroll opencode up" })
  vim.keymap.set("n", "<M-d>", function() require("opencode").command("session.half.page.down") end,
    { desc = "Scroll opencode down" })

  -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
  vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
  vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
end

return O
