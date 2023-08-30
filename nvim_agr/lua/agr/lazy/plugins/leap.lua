local L = {
  'ggandor/leap.nvim',
  event = 'BufReadPre',
}

L.config = function ()
  local leap = require 'leap'

  leap.setup {}

  leap.opts.safe_labels = {}
end

return L
