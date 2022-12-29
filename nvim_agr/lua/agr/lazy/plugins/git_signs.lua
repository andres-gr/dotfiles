local G = {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
}

G.config = function ()
  local gitsigns = require 'gitsigns'

  gitsigns.setup {
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_formatter_opts = {
      relative_time = false,
    },
    current_line_blame_opts = {
      delay = 1000,
      ignore_whitespace = false,
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    },
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    max_file_length = 40000,
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    preview_config = {
      -- Options passed to nvim_open_win
      border = 'single',
      col = 1,
      relative = 'cursor',
      row = 0,
      style = 'minimal',
    },
    sign_priority = 6,
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    signs = {
      add = {
        hl = 'GitSignsAdd',
        linehl = 'GitSignsAddLn',
        numhl = 'GitSignsAddNr',
        text = '▎',
      },
      change = {
        hl = 'GitSignsChange',
        linehl = 'GitSignsChangeLn',
        numhl = 'GitSignsChangeNr',
        text = '▎',
      },
      changedelete = {
        hl = 'GitSignsChange',
        linehl = 'GitSignsChangeLn',
        numhl = 'GitSignsChangeNr',
        text = '▎',
      },
      delete = {
        hl = 'GitSignsDelete',
        linehl = 'GitSignsDeleteLn',
        numhl = 'GitSignsDeleteNr',
        text = '契',
        -- text = '▎',
      },
      topdelete = {
        hl = 'GitSignsDelete',
        linehl = 'GitSignsDeleteLn',
        numhl = 'GitSignsDeleteNr',
        text = '契',
      },
    },
    status_formatter = nil, -- Use default
    update_debounce = 100,
    watch_gitdir = {
      follow_files = true,
      interval = 1000,
    },
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    yadm = {
      enable = false,
    },
  }

  local scrollbar = require 'scrollbar.handlers.gitsigns'

  scrollbar.setup()
end

return G
