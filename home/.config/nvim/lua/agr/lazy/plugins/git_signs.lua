local G = {
  'lewis6991/gitsigns.nvim',
  event = {
    'BufNewFile',
    'BufReadPost',
  },
}

G.config = function ()
  local gitsigns = require 'gitsigns'

  gitsigns.setup {
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    current_line_blame_opts = {
      delay = 1000,
      ignore_whitespace = false,
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      virt_text_priority = 100,
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
      add = { text = '▎' },
      change = { text = '▎' },
      changedelete = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      untracked = { text = '┆' },
    },
    status_formatter = nil, -- Use default
    update_debounce = 100,
    watch_gitdir = {
      follow_files = true,
      interval = 1000,
    },
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  }

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '<leader>gk', '<CMD>Gitsigns prev_hunk<CR>zz', desc_opts('Git prev hunk'))
  map('n', '<leader>gj', '<CMD>Gitsigns next_hunk<CR>zz', desc_opts('Git next hunk'))
  map('n', '<leader>gl', '<CMD>Gitsigns blame_line<CR>', desc_opts('Git blame line'))
  map('n', '<leader>gp', '<CMD>Gitsigns preview_hunk<CR>', desc_opts('Git preview hunk'))
  map('n', '<leader>ghr', '<CMD>Gitsigns reset_hunk<CR>', desc_opts('Git reset hunk'))
  map('n', '<leader>gbr', '<CMD>Gitsigns reset_buffer<CR>', desc_opts('Git reset buffer'))
  map('n', '<leader>ghs', '<CMD>Gitsigns stage_hunk<CR>', desc_opts('Git stage hunk'))
  map('n', '<leader>ghu', '<CMD>Gitsigns undo_stage_hunk<CR>', desc_opts('Git unstage hunk'))
  map('n', '<leader>Gd', '<CMD>Gitsigns diffthis<CR>', desc_opts('Git view diff'))

  local scrollbar = require 'scrollbar.handlers.gitsigns'

  scrollbar.setup()
end

return G
