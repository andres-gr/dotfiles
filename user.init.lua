local bgColor = "#424450"

local config = {
  colorscheme = "dracula",
  highlights = {
    dracula = {
      CursorLine = { bg = "#2B2640" },
      LspReferenceText = { bg = bgColor, fg = "NONE", },
      LspReferenceRead = { bg = bgColor, fg = "NONE", },
      LspReferenceWrite = { bg = bgColor, fg = "NONE", },
    },
  },
  plugins = {
    init = {
      ["declancm/cinnamon.nvim"] = { disable = true },
      {
        "xiyaowong/nvim-transparent",
        config = function ()
          require("transparent").setup({
            enable = true,
            extra_groups = {
            --   "BufferLineTabClose",
            --   "BufferlineBufferSelected",
            --   "BufferLineFill",
            --   "BufferLineBackground",
            --   "BufferLineSeparator",
            --   "BufferLineIndicatorSelected",
              "NeoTreeNormal",
              "NeoTreeNormalNC",
            },
          })
        end,
      },
      {
        "kylechui/nvim-surround",
        tag = "*",
        config = function ()
          require("nvim-surround").setup({})
        end,
      },
      { "tpope/vim-repeat" },
      { "ggandor/lightspeed.nvim" },
      {
        "Mofiqul/dracula.nvim",
        config = function ()
          require("dracula").setup({
            colors = {
              bg = "#22212C",
              fg = "#F8F8F2",
              selection = "#454158",
              comment = "#7970A9",
              red = "#FF9580",
              orange = "#FFCA80",
              yellow = "#FFFF80",
              green = "#8AFF80",
              purple = "#9580FF",
              cyan = "#80FFEA",
              pink = "#FF80BF",
              bright_red = "#FFBFB3",
              bright_green = "#B9FFB3",
              bright_yellow = "#FFFFB3",
              bright_blue = "#BFB3FF",
              bright_magenta = "#FFB3D9",
              bright_cyan = "#B3FFF2",
              bright_white = "#FFFFFF",
              menu = "#2B2640",
              visual = "#424450",
              gutter_fg = "#4B5263",
              nontext = "#3B4048",
            },
            italic_comment = true,
            transparent_bg = true,
          })
        end,
      },
      { "manzeloth/live-server" },
      {
        "glepnir/lspsaga.nvim",
        config = function ()
          local saga = require("lspsaga")
          saga.init_lsp_saga()
        end,
      },
    },
    bufferline = {
      options = {
        separator_style = "thin"
      },
    },
    colorizer = {
      user_default_options = {
        css_fn = true,
        names = false,
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
      },
    },
    ["neo-tree"] = {
      window = {
        width = 45,
      },
    },
    notify = {
      background_colour = "#000000",
    },
    telescope = {
      defaults = {
        initial_mode = "normal",
      },
    },
    treesitter = {
      indent = { enable = true },
      ensure_installed = "all",
      ignore_installed = { "javascript" },
      auto_install = true,
    },
  },
  options = {
    g = {
      transparent_enabled = true,
    },
  },
  polish = function ()
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
    parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
  end,
}

return config

