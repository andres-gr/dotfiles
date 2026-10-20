local E = {
  'max397574/better-escape.nvim',
  event = 'InsertEnter',
  opts = {
    default_mappings = true,
    timeout = vim.o.timeoutlen,
  },
  config = function (_, opts)
    require('better_escape').setup(opts)

    -- better-escape also installs expr-maps for `j`/`k` in Select mode. There
    -- they swallow the first `j` and leave a dangling selection/visual state
    -- instead of resolving the `jk` sequence, so drop them. Select-mode
    -- escaping is handled by the explicit `s` map in core/maps.lua.
    pcall(vim.keymap.del, 's', 'j')
    pcall(vim.keymap.del, 's', 'k')
  end,
}

return E
