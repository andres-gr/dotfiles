local P = {
  ['declancm/cinnamon.nvim'] = { disable = true },
  {
    'kylechui/nvim-surround',
    tag = '*',
    config = function ()
      require('nvim-surround').setup({})
    end,
  },
  { 'tpope/vim-repeat' },
  { 'ggandor/lightspeed.nvim' },
  {
    'Mofiqul/dracula.nvim',
    config = function ()
      require('dracula').setup({
        colors = {
          bg = '#22212C',
          fg = '#F8F8F2',
          selection = '#454158',
          comment = '#7970A9',
          red = '#FF9580',
          orange = '#FFCA80',
          yellow = '#FFFF80',
          green = '#8AFF80',
          purple = '#9580FF',
          cyan = '#80FFEA',
          pink = '#FF80BF',
          bright_red = '#FFBFB3',
          bright_green = '#B9FFB3',
          bright_yellow = '#FFFFB3',
          bright_blue = '#BFB3FF',
          bright_magenta = '#FFB3D9',
          bright_cyan = '#B3FFF2',
          bright_white = '#FFFFFF',
          menu = '#2B2640',
          visual = '#424450',
          gutter_fg = '#4B5263',
          nontext = '#3B4048',
        },
        italic_comment = true,
        transparent_bg = true,
      })
    end,
  },
  { 'manzeloth/live-server' },
  {
    'xiyaowong/nvim-transparent',
    config = function ()
      require('transparent').setup({
        enable = true,
        extra_groups = {
          'BufferLineTabClose',
          'BufferlineBufferSelected',
          'BufferLineFill',
          'BufferLineBackground',
          'BufferLineSeparator',
          'BufferLineIndicatorSelected',
          'NeoTreeNormal',
          'NeoTreeNormalNC',
        },
      })
    end,
  },
}

return P

