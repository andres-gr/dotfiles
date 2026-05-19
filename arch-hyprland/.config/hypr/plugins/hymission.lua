-------------------------------
--- HYMISSION CONFIGURATION ---
-------------------------------

local mod = require 'utils.mod_key'

if hl.plugin.hymission ~= nil then
  hl.unbind(mod .. ' + TAB')
  hl.unbind(mod .. ' + SHIFT + TAB')

  hl.config {
    plugin = {
      hymission = {
        max_preview_scale = 0.75,
        show_focus_indicator = false,
        workspace_strip_anchor = 'left',
        workspace_strip_gap = 32,
        workspace_strip_thickness = 240,
      },
    },
  }

  hl.bind(mod .. ' + TAB', hl.plugin.hymission 'toggle', {
    description = 'Toggle overview for all workspaces',
  })
  hl.bind(mod .. 'A', hl.plugin.hymission 'open', {
    description = 'Toggle overview for current workspace',
  })
end
