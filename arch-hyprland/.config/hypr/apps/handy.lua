-------------------------------
--- HANDY CONFIGURATION -----
-------------------------------

local has_command = require 'utils.has_command'

if has_command 'handy' then
  hl.unbind 'CTRL + SHIFT + SPACE'

  -- 16. Vicinae Launcher
  hl.bind('CTRL + SHIFT + SPACE', hl.dsp.exec_cmd 'handy --toggle-transcription', {
    description = 'Toggle Handy Dictation',
  })
end
