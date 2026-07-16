hl.on('hyprland.start', function()
  local home = os.getenv 'HOME'

  hl.exec_cmd(
    'sleep 0.7; STARTUP_SPLASH={{splash}} STARTUP_SPLASH_DURATION={{duration}} STARTUP_SPLASH_VOLUME={{volume}} ' ..
    home .. '/.local/bin/splash-screen-animation')
end)

pcall(require, 'splash_temp_binds')
