hl.on('hyprland.start', function()
  local home = os.getenv('HOME')

  hl.exec_cmd 'noctalia'
  hl.exec_cmd(home .. '/.local/bin/idle-pre-lock')
  hl.exec_cmd(home .. '/.local/bin/media-idle-inhibit')
end)
