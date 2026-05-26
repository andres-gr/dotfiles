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

  hl.bind(mod .. ' + TAB', function()
    hl.plugin.hymission.toggle('forceall')
  end, {
    description = 'Toggle overview for all workspaces',
  })
  hl.bind(mod .. '+ A', function ()
    hl.plugin.hymission.open('onlycurrentworkspace')
  end, {
    description = 'Toggle overview for current workspace',
  })
end
