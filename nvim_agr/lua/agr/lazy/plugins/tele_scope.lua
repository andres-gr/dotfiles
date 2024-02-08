local T = {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'danielvolchek/tailiscope.nvim',
  },
}

T.config = function ()
  local telescope = require 'telescope'
  local utils = require 'agr.core.utils'
  local actions = require 'telescope.actions'
  local project = utils.has_plugin 'project_nvim.project'

  local cwd = project ~= nil and project.get_project_root() or nil

  telescope.setup {
    extensions = {
      fzf = {
        case_mode = 'smart_case', -- or 'ignore_case' or 'respect_case'
        fuzzy = true, -- false will only do exact matching
        override_file_sorter = true, -- override the file sorter
        override_generic_sorter = true, -- override the generic sorter
      },
    },
    defaults = {
      dynamic_preview_title = true,
      file_ignore_patterns = {
        '^.git.',
      },
      initial_mode = 'normal',
      layout_config = {
        height = 0.80,
        horizontal = {
          preview_width = 0.55,
          prompt_position = 'top',
          results_width = 0.8,
        },
        preview_cutoff = 120,
        vertical = {
          mirror = false,
        },
        width = 0.85,
      },
      layout_strategy = 'horizontal',
      path_display = {
        truncate = 3,
      },
      prompt_prefix = '  ',
      prompt_title = false,
      selection_caret = '❯ ',
      selection_strategy = 'reset',
      set_env = {
        ['COLORTERM'] = 'truecolor',
      },
      sorting_strategy = 'ascending',
      mappings = {
        i = {
          ['<C-n>'] = actions.move_selection_next,
          ['<C-p>'] = actions.move_selection_previous,

          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,

          ['<C-c>'] = actions.close,
          ['<C-e>'] = actions.close,

          ['<Down>'] = actions.move_selection_next,
          ['<Up>'] = actions.move_selection_previous,

          ['<CR>'] = actions.select_default,
          ['<C-x>'] = actions.select_horizontal,
          ['<C-v>'] = actions.select_vertical,
          ['<C-t>'] = actions.select_tab,

          ['<C-u>'] = actions.preview_scrolling_up,
          ['<C-d>'] = actions.preview_scrolling_down,

          ['<PageUp>'] = actions.results_scrolling_up,
          ['<PageDown>'] = actions.results_scrolling_down,

          ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
          ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
          ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
          ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
          ['<C-l>'] = actions.complete_tag,
          ['<C-h>'] = actions.which_key,
        },
        n = {
          ['<esc>'] = actions.close,
          ['<C-c>'] = actions.close,
          ['<C-e>'] = actions.close,
          ['q'] = actions.close,
          ['<CR>'] = actions.select_default,
          ['<C-x>'] = actions.select_horizontal,
          ['<C-v>'] = actions.select_vertical,
          ['<C-t>'] = actions.select_tab,

          ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
          ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
          ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
          ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

          ['j'] = actions.move_selection_next,
          ['k'] = actions.move_selection_previous,
          ['H'] = actions.move_to_top,
          ['M'] = actions.move_to_middle,
          ['L'] = actions.move_to_bottom,

          ['<Down>'] = actions.move_selection_next,
          ['<Up>'] = actions.move_selection_previous,
          ['gg'] = actions.move_to_top,
          ['G'] = actions.move_to_bottom,

          ['<C-u>'] = actions.preview_scrolling_up,
          ['<C-d>'] = actions.preview_scrolling_down,

          ['<PageUp>'] = actions.results_scrolling_up,
          ['<PageDown>'] = actions.results_scrolling_down,
          ['<C-b>'] = actions.results_scrolling_up,
          ['<C-f>'] = actions.results_scrolling_down,
          ['<C-h>'] = actions.which_key,
          ['?'] = actions.which_key,
        },
      },
    },
    pickers = {
      aerial = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      buffers = {
        mappings = {
          i = {
            ['<C-d>'] = actions.delete_buffer,
          },
          n = {
            ['dd'] = actions.delete_buffer,
          },
        },
        prompt_title = false,
      },
      commands = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      diagnostics = {
        prompt_title = false,
      },
      find_files = {
        cwd = cwd,
        initial_mode = 'insert',
        hidden = true,
        prompt_title = false,
      },
      git_status = {
        prompt_title = false,
      },
      grep_string = {
        cwd = cwd,
        prompt_title = false,
      },
      help_tags = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      highlights = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      keymaps = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      live_grep = {
        cwd = cwd,
        initial_mode = 'insert',
        only_sort_text = true,
        prompt_title = false,
      },
      lsp_references = {
        prompt_title = false,
      },
      lsp_workspace_symbols = {
        initial_mode = 'insert',
        prompt_title = false,
      },
      notify = {
        prompt_title = false,
      },
      oldfiles = {
        only_cwd = true,
        prompt_title = false,
      },
      registers = {
        prompt_title = false,
      },
    },
  }

  local keymap = utils.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  local builtins = require 'telescope.builtin'
  map('n', '<leader>fw', builtins.live_grep, desc_opts('Search words'))
  map('n', '<leader>fW', function () builtins.live_grep({
    additional_args = function (args)
      return vim.list_extend(args, {
        '--hidden',
        '--no-ignore',
      })
    end,
  }) end, desc_opts('Search words in all files'))
  map('n', '<leader>ff', builtins.find_files, desc_opts('Search files'))
  map('n', '<leader>fF', function () builtins.find_files { no_ignore = true } end, desc_opts('Search all files'))
  map('n', '<leader>fb', builtins.buffers, desc_opts('Search buffers'))
  map('n', '<leader>fh', builtins.help_tags, desc_opts('Search help'))
  map('n', '<leader>fH', function () builtins.highlights {
    attach_mappings = function (_, _map)
      _map('i', '<C-y>', function ()
        local entry = require 'telescope.actions.state'.get_selected_entry()
        vim.fn.setreg('*', entry.value)
        vim.notify('Yanked ' .. entry.value)
      end)

      _map('n', '<C-y>', function ()
        local entry = require 'telescope.actions.state'.get_selected_entry()
        vim.fn.setreg('*', entry.value)
        vim.notify('Yanked ' .. entry.value)
      end)

      return true
    end,
  } end, desc_opts('Search highlights'))
  map('n', '<leader>fo', builtins.oldfiles, desc_opts('Search file history'))
  map('n', '<leader>fc', builtins.grep_string, desc_opts('Search word under cursor'))
  map('n', '<leader>fr', builtins.registers, desc_opts('Search registers'))
  map('n', '<leader>fk', builtins.keymaps, desc_opts('Search keymaps'))
  map('n', '<leader>fn', builtins.commands, desc_opts('Search commands'))
  map('n', '<leader>fg', builtins.git_status, desc_opts('Search git status'))
  map('n', '<leader>lg', builtins.lsp_workspace_symbols, desc_opts('Search workspace symbols'))
  map('n', '<leader>lr', builtins.lsp_references, desc_opts('Search references'))
  map('n', '<leader>ld', builtins.diagnostics, desc_opts('Search diagnostics'))

  if utils.has_plugin 'aerial' then
    telescope.load_extension('aerial')
    map('n', '<leader>fa', '<CMD>Telescope aerial<CR>', desc_opts('Search symbols'))
  end

  if utils.has_plugin 'notify' then
    telescope.load_extension('notify')
    map('n', '<leader>fm', '<CMD>Telescope notify<CR>', desc_opts('Search messages'))
  end

  if project then
    telescope.load_extension('projects')
  end
end

return T
