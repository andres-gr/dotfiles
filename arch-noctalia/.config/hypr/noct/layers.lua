hl.layer_rule {
  name = 'noctalia',
  match = {
    namespace = 'noctalia-background-.*$',
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.5,
}
