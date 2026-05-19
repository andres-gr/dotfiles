-------------------------------
---- ANIMATION CURVES ---------
-------------------------------

hl.curve('linear', {
  type = 'bezier',
  points = {
    { 1, 1 },
    { 1, 1 }
  },
})

hl.curve('wind', {
  type = 'bezier',
  points = {
    { 0.05, 0.9 },
    { 0.1,  1.05 }
  },
})

hl.curve('winIn', {
  type = 'bezier',
  points = {
    { 0.1, 1.1 },
    { 0.1, 1.1 }
  },
})

hl.curve('winOut', {
  type = 'bezier',
  points = {
    { 0.3, -0.3 },
    { 0,   1 }
  },
})

hl.curve('easeOutExpo', {
  type = 'bezier',
  points = {
    { 0.1, 1 },
    { 0.2, 1 }
  },
})


-------------------------------
---- ANIMATION FUNCTIONS ------
-------------------------------

hl.animation({
  leaf = 'windows',
  enabled = true,
  speed = 4,
  bezier = 'wind',
  style = 'slide',
})

hl.animation({
  leaf = 'windowsIn',
  enabled = true,
  speed = 4,
  bezier = 'winIn',
  style = 'slide',
})

hl.animation({
  leaf = 'windowsOut',
  enabled = true,
  speed = 3,
  bezier = 'winOut',
  style = 'slide',
})

hl.animation({
  leaf = 'windowsMove',
  enabled = true,
  speed = 3,
  bezier = 'default',
  style = 'slide',
})

hl.animation({
  leaf = 'border',
  enabled = true,
  speed = 1,
  bezier = 'linear',
})

hl.animation({
  leaf = 'borderangle',
  enabled = true,
  speed = 20,
  bezier = 'linear',
  style = 'loop',
})

hl.animation({
  leaf = 'fade',
  enabled = true,
  speed = 10,
  bezier = 'default',
})

hl.animation({
  leaf = 'workspaces',
  enabled = true,
  speed = 8,
  bezier = 'easeOutExpo',
})
