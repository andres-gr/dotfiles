-------------------------------
---- INPUT CONFIGURATION ------
-------------------------------

hl.config {
  cursor = {
    hide_on_key_press = true,
    no_hardware_cursors = true,
  },
  input = {
    follow_mouse = true,
    kb_layout = 'us',
    kb_options = 'fkeys:basic_13-24',
    kb_variant = 'altgr-intl',
    repeat_delay = 250,
    repeat_rate = 40,
    sensitivity = -0.4,
    touchpad = {
      natural_scroll = true,
    },
  },
}

hl.on('hyprland.start', function()
  hl.exec_cmd 'hyprctl setcursor Bibata-Rainbow-Modern 24'
end)
