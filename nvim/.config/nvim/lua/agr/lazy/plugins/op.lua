local O = {
  'nickjvandyke/opencode.nvim',
  branch = 'main',
  dependencies = {
    {
      'folke/snacks.nvim',
      optional = true,
    },
  },
}

O.config = function ()
  -- Dynamically update theme env var before each toggle
  -- This ensures the theme matches vim.o.background at the time opencode is opened
  local original_toggle = require('opencode').toggle
  require('opencode').toggle = function (...)
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
  vim.keymap.set({ 'n', 'x' }, '<M-.>', function () require('opencode').ask('@this: ', { submit = true }) end,
    { desc = 'Ask opencode…' })
  vim.keymap.set({ 'n', 'x' }, '<M-,>', function () require('opencode').ask('', { submit = true }) end,
    { desc = 'Empty ask opencode…' })
  vim.keymap.set({ 'n', 'x' }, '<M-/>', function () require('opencode').select() end,
    { desc = 'Execute opencode action…' })

  vim.keymap.set({ 'n', 'x' }, '<leader>go', function () return require('opencode').operator('@this ') end,
    { desc = 'Add range to opencode', expr = true })
  vim.keymap.set('n', 'goo', function () return require('opencode').operator('@this ') .. '_' end,
    { desc = 'Add line to opencode', expr = true })
  vim.keymap.set('n', 'gos', function () return require('opencode').command('prompt.submit') end,
    { desc = 'Submit prompt' })
  vim.keymap.set('n', 'goc', function () return require('opencode').command('prompt.clear') end,
    { desc = 'Clear prompt' })

  -- Scroll the opencode v2 TUI from nvim via tmux.
  -- V2 removed the server-side built-in `session.*` command registry, so
  -- opencode.nvim's `command()` API can no longer scroll the TUI
  -- (POST /api/session/<id>/command runs only user-defined prompt commands).
  -- Instead, locate the tmux pane running `opencode` and send its own TUI
  -- scroll keybinds (default ctrl+alt+u / ctrl+alt+d) into that pane's PTY.
  local function opencode_pane_id()
    local out = vim.fn.systemlist({ 'tmux', 'list-panes', '-a', '-F', '#{pane_current_command}|#{pane_id}' })
    if vim.v.shell_error ~= 0 then return nil, 'tmux unavailable' end
    for _, line in ipairs(out) do
      local cmd, pane = line:match('^([^|]+)|(.+)$')
      if cmd == 'opencode' then return pane end
    end
    return nil, 'no opencode pane'
  end

  local function scroll_opencode(keys)
    local pane, err = opencode_pane_id()
    if not pane then
      vim.notify(('Cannot scroll opencode: %s'):format(err), vim.log.levels.WARN)
      return
    end
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane, keys })
  end

  vim.keymap.set('n', '<M-u>', function () scroll_opencode('C-M-u') end,
    { desc = 'Scroll opencode pane half page up' })
  vim.keymap.set('n', '<M-d>', function () scroll_opencode('C-M-d') end,
    { desc = 'Scroll opencode pane half page down' })
end

return O
