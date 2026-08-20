hl.layer_rule {
  name = 'noctalia',
  match = {
    namespace = '^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$',
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.5,
  no_anim = true,
}
