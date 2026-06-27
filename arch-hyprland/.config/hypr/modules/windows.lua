-------------------------------
---- WINDOWS CONFIGURATION ----
-------------------------------

local match_classes = require 'utils.match_classes'
local merge_tables  = require 'utils.merge_tables'

local media_players = {
  '.*mpv.*',
  '.*vlc.*',
  'org.kde.haruna',
  'org.nomacs.ImageLounge',
}

hl.window_rule {
  name = 'media_players',
  match = {
    class = match_classes(media_players),
  },
  center = true,
  float = true,
  opacity = '1 override',
  size = {
    '(monitor_w*0.95)',
    '(monitor_h*0.95)',
  },
}

local idle_inhibit_fullscreen_apps = {
  '.*[Ss]potify.*',
  '.*brave-browser.*',
  '.*celluloid.*',
  '.*chromium.*',
  '.*firefox.*',
  '.*floorp.*',
  '.*LibreWolf.*',
  '.*vivaldi.*',
  '.*zen.*',
}

hl.window_rule {
  name = 'idle_inhibit_fullscreen_apps',
  match = {
    class = match_classes(merge_tables(idle_inhibit_fullscreen_apps, media_players)),
    fullscreen = true,
  },
  idle_inhibit = 'fullscreen',
}

hl.window_rule {
  name = 'hypr_picture_in_picture',
  match = {
    title = '^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$',
  },
  tag = '+hypr_picture_in_picture',
  float = true,
  keep_aspect_ratio = true,
  pin = true,
  move = {
    '(monitor_w*0.73)',
    '(monitor_h*0.72)',
  },
  size = {
    '(monitor_w*0.25)',
    '(monitor_h*0.25)',
  },
}

local various_float_util_apps = {
  'app.drey.Warp',
  'com.github.rafostar.Clapper',
  'com.github.unrud.VideoDownloader',
  'eog',
  'io.github.alainm23.planify',
  'io.gitlab.adhami3310.Impression',
  'io.gitlab.theevilskeleton.Upscaler',
  'io.missioncenter.MissionCenter',
  'net.davidotek.pupgui2',
  'nwg-displays',
  'org.wezfurlong.wezterm',
  'Signal',
  'yad',
}

hl.window_rule {
  name = 'various_float_util_apps',
  match = {
    class = match_classes(various_float_util_apps),
  },
  float = true,
}

local various_float_util_firefox = {
  '.*firefox.*',
  '.*zen.*',
}

hl.window_rule {
  name = 'various_float_util_firefox',
  match = {
    class = match_classes(various_float_util_firefox),
    title = '^(Library)$'
  },
  center = true,
  float = true,
  size = {
    '(monitor_w*0.8)',
    '(monitor_h*0.8)',
  },
}

hl.window_rule {
  name = 'various_float_util_zoom',
  match = {
    class = '^([Zz]oom)$',
    initial_class = '^([Zz]oom)$'
  },
  float = true,
}

hl.window_rule {
  name = 'jetbrains_dropdowns_popups',
  match = {
    class = '^(.*jetbrains.*)$',
    title = '^(win[0-9]+)$',
  },
  no_initial_focus = true,
}

hl.window_rule {
  name = 'zoom_specifics_options',
  match = {
    class = '^(.*[Zz]oom.*)$',
    title = '^(Choose.*)',
  },
  pin = true,
}

hl.window_rule {
  name = 'xwayland_video_bridge',
  match = {
    class = 'xwaylandvideobridge',
  },
  max_size = { 1, 1 },
  no_anim = true,
  no_blur = true,
  no_focus = true,
  no_initial_focus = true,
  opacity = '0.0 override',
}

hl.window_rule {
  name = 'spotify_to_workspace',
  match = {
    class = '^(.*[Ss]potify.*)$',
  },
  workspace = 'name:prim4 silent',
}

hl.window_rule {
  name = 'whatsapp_to_workspace',
  match = {
    class = '^(com.rtosta.zapzap)$',
  },
  workspace = 'name:sec3',
}

hl.window_rule {
  name = 'claude_to_workspace',
  match = {
    class = '^([Cc]laude.*)',
  },
  workspace = 'name:sec4',
}

hl.window_rule {
  name = 'update_packages',
  match = {
    class = '^(com.mitchellh.ghostty)$',
    initial_title = '^(System Update)$',
  },
  center = true,
  float = true,
  size = {
    '(monitor_w*0.6)',
    '(monitor_h*0.8)',
  },
}

hl.window_rule {
  name = 'screenshot_annotate_tool',
  match = {
    class = '^(com.gabm.satty)$',
    initial_title = '^(satty)$',
  },
  center = true,
  float = true,
  size = {
    '(monitor_w*0.8)',
    '(monitor_h*0.8)',
  },
}

hl.window_rule {
  name = 'xdg_desktop_portal',
  match = {
    class = '^([Xx]dg-desktop-portal.*)',
  },
  center = true,
  float = true,
  size = {
    '(monitor_w*0.4)',
    '(monitor_h*0.5)',
  },
}

hl.window_rule {
  name = 'pygame_float',
  match = {
    class = '^(main.py)',
    title = '^(pygame.*)',
  },
  center = true,
  float = true,
}
