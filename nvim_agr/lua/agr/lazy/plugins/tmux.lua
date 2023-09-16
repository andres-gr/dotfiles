local T = {
  'christoomey/vim-tmux-navigator',
  event = 'VeryLazy',
}

T.init = function ()
  vim.g.tmux_navigator_disable_when_zoomed = 1
end

return T
