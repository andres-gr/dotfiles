local L = {
  'ggandor/leap.nvim',
  event = 'VeryLazy',
}

L.config = function ()
  local leap = require 'leap'

  leap.setup {}

  leap.opts.safe_labels = {}
end

return L
