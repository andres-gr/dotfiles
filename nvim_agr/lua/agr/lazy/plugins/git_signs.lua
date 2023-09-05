local G = {
  'lewis6991/gitsigns.nvim',
  event = {
    'BufNewFile',
    'BufReadPre',
  },
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
        text = '',
        -- text = '▎',
      },
      topdelete = {
        hl = 'GitSignsDelete',
        linehl = 'GitSignsDeleteLn',
        numhl = 'GitSignsDeleteNr',
        text = '',
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

  local map = vim.keymap.set
  local opts = {
    remap = false,
    silent = true,
  }
  local desc_opts = function (desc)
    local result = { desc = desc }

    for key, val in pairs(opts) do
      result[key] = val
    end

    return result
  end

  local blame_line = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns blame_line")<CR>'
  local preview_hunk = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns preview_hunk")<CR>'

  map('n', '<leader>gk', '<CMD>Gitsigns prev_hunk<CR>zz', desc_opts('Git prev hunk'))
  map('n', '<leader>gj', '<CMD>Gitsigns next_hunk<CR>zz', desc_opts('Git next hunk'))
  map('n', '<leader>gl', blame_line, desc_opts('Git blame line'))
  map('n', '<leader>gp', preview_hunk, desc_opts('Git preview hunk'))
  map('n', '<leader>ghr', '<CMD>Gitsigns reset_hunk<CR>', desc_opts('Git reset hunk'))
  map('n', '<leader>gbr', '<CMD>Gitsigns reset_buffer<CR>', desc_opts('Git reset buffer'))
  map('n', '<leader>ghs', '<CMD>Gitsigns stage_hunk<CR>', desc_opts('Git stage hunk'))
  map('n', '<leader>ghu', '<CMD>Gitsigns undo_stage_hunk<CR>', desc_opts('Git unstage hunk'))
  map('n', '<leader>Gd', '<CMD>Gitsigns diffthis<CR>', desc_opts('Git view diff'))

  local scrollbar = require 'scrollbar.handlers.gitsigns'

  scrollbar.setup()
end

return G
