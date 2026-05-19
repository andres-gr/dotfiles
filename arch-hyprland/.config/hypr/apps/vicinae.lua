-------------------------------
--- VICINAE CONFIGURATION -----
-------------------------------

local has_command = require 'utils.has_command'

if has_command 'vicinae' then
  hl.on('hyprland.start', function()
    hl.exec_cmd 'vicinae server'
  end)

  hl.layer_rule {
    name = 'vicinae_layer',
    match = {
      namespace = 'vicinae',
    },
    blur = true,
    ignore_alpha = 0,
    no_anim = true,
  }

  hl.unbind 'ALT + SPACE'

  hl.bind('ALT + SPACE', hl.dsp.exec_cmd 'vicinae toggle', {
    description = 'Toggle Vicinae Launcher',
  })
end
