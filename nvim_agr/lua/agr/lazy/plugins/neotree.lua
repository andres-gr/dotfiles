local N = {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  dependencies = {
    {
      'MunifTanjim/nui.nvim',
      lazy = true,
    },
  },
  init = function () vim.g.neo_tree_remove_legacy_commands = true end,
}

N.config = function ()
  local neo_tree = require 'neo-tree'
  local neo_utils = require 'neo-tree.utils'
  local fs = require 'neo-tree.sources.filesystem'
  local utils = require 'agr.core.utils'

  local toggle_dir = function (state, node)
    fs.toggle_directory(state, node, nil, false, false)
    return true
  end

  -- toggle a node open or descend to it's first child
  local dive = function (state)
    local tree = state.tree
    local node = tree:get_node()

    if not neo_utils.is_expandable(node) then return end

    if not node:is_expanded() then
      toggle_dir(state, node)

      vim.fn.feedkeys(utils.key_down)
    end
  end

  neo_tree.setup {
    buffers = {
      follow_current_file = true, -- This will find and focus the file in the active buffer every
      -- time the current file is changed while the tree is open.
      group_empty_dirs = true, -- when true, empty folders will be grouped together
      show_unloaded = true,
      window = {
        mappings = {
          ['bd'] = 'buffer_delete',
          ['<bs>'] = 'navigate_up',
          ['.'] = 'set_root',
        }
      },
    },
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    default_component_configs = {
      container = {
        enable_character_fade = true,
      },
      indent = {
        indent_size = 2,
        padding = 1, -- extra padding on left hand side
        -- indent guides
        highlight = 'NeoTreeIndentMarker',
        indent_marker = '│',
        last_indent_marker = '└',
        with_markers = true,
        -- expander config, needed for nesting files
        expander_collapsed = '',
        expander_expanded = '',
        expander_highlight = 'NeoTreeExpander',
        with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      },
      icon = {
        folder_closed = '',
        folder_empty = '󰉖',
        folder_open = '',
        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
        -- then these will never be used.
        default = '*',
        highlight = 'NeoTreeFileIcon'
      },
      modified = {
        highlight = 'NeoTreeModified',
        symbol = '',
      },
      name = {
        highlight = 'NeoTreeFileName',
        trailing_slash = false,
        use_git_status_colors = true,
      },
      git_status = {
        symbols = {
          -- Change type
          added     = '✚', -- or '✚', but this is redundant info if you use git_status_colors on the name
          deleted   = '✖', -- this can only be used in the git_status source
          modified  = '', -- or '', but this is redundant info if you use git_status_colors on the name
          renamed   = '', -- this can only be used in the git_status source
          -- Status type
          conflict  = '',
          ignored   = '',
          staged    = '',
          unstaged  = '󰆢',
          untracked = '',
        },
      },
    },
    enable_diagnostics = true,
    enable_git_status = true,
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function () vim.opt_local.signcolumn = 'auto' end,
      },
    },
    filesystem = {
      async_directory_scan = 'auto',
      filtered_items = {
        always_show = {}, -- remains visible even if other settings would normally hide it
        hide_by_name = {
          'node_modules',
        },
        hide_by_pattern = { -- uses glob style patterns
          --'*.meta',
          --'*/src/*/tsconfig.json',
        },
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false, -- only works on Windows for hidden files/directories
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          --'.DS_Store',
          --'thumbs.db'
          '.git',
        },
        never_show_by_pattern = { -- uses glob style patterns
          --'.null-ls_*',
        },
      },
      follow_current_file = true, -- This will find and focus the file in the active buffer every
      -- time the current file is changed while the tree is open.
      group_empty_dirs = false, -- when true, empty folders will be grouped together
      -- hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
      -- in whatever position is specified in window.position
      hijack_netrw_behavior = 'open_current', -- netrw disabled, opening a directory opens neo-tree
      -- 'open_current',  -- netrw disabled, opening a directory opens within the
      -- window like netrw would, regardless of window.position
      -- 'disabled',    -- netrw left alone, neo-tree does not handle opening dirs
      use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
      -- instead of relying on nvim autocmd events.
      visible = true, -- when true, they will just be displayed differently than normal items
      window = {
        mappings = {
          ['<bs>'] = 'navigate_up',
          ['.'] = 'set_root',
          ['H'] = 'toggle_hidden',
          ['/'] = 'fuzzy_finder',
          ['D'] = 'fuzzy_finder_directory',
          ['f'] = 'filter_on_submit',
          ['<c-x>'] = 'clear_filter',
          ['g['] = 'prev_git_modified',
          ['g]'] = 'next_git_modified',
        },
      },
    },
    git_status = {
      window = {
        mappings = {
          ['A']  = 'git_add_all',
          ['gu'] = 'git_unstage_file',
          ['ga'] = 'git_add_file',
          ['gr'] = 'git_revert_file',
          ['gc'] = 'git_commit',
          ['gp'] = 'git_push',
          ['gg'] = 'git_commit_and_push',
        },
        position = 'float',
      },
    },
    nesting_rules = {},
    popup_border_style = 'rounded',
    sort_case_insensitive = false, -- used when sorting files and directories in the tree
    sort_function = nil, -- use a custom function for sorting files and directories in the tree
    source_selector = {
      content_layout = 'center',
      sources = {
        buffers = '  Buffers ',
        diagnostics = ' 裂Diagnostics ',
        filesystem = '  Files ',
        git_status = '  Git ',
      },
      -- winbar = true,
    },
    window = {
      mapping_options = {
        noremap = true,
        nowait = false,
      },
      mappings = {
        ['<space>'] = false,
        -- ['<space>'] = {
        --   'toggle_node',
        --   nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
        -- },
        ['<2-LeftMouse>'] = 'open',
        ['<cr>'] = 'open',
        ['o'] = 'open',
        ['<esc>'] = 'revert_preview',
        ['<M-o>'] = 'revert_preview',
        ['P'] = { 'toggle_preview', config = { use_float = true } },
        ['S'] = 'open_split',
        ['s'] = 'open_vsplit',
        -- ['S'] = 'split_with_window_picker',
        -- ['s'] = 'vsplit_with_window_picker',
        ['t'] = 'open_tabnew',
        -- ['<cr>'] = 'open_drop',
        -- ['t'] = 'open_tab_drop',
        ['w'] = 'open_with_window_picker',
        --['P'] = 'toggle_preview', -- enter preview mode, which shows the current node without focusing
        ['C'] = 'close_node',
        ['h'] = 'close_node',
        ['l'] = dive,
        -- ['l'] = 'toggle_node',
        ['z'] = 'close_all_nodes',
        ['Z'] = 'expand_all_nodes',
        ['a'] = {
          'add',
          -- some commands may take optional config options, see `:h neo-tree-mappings` for details
          config = {
            show_path = 'none' -- 'none', 'relative', 'absolute'
          }
        },
        ['A'] = 'add_directory', -- also accepts the optional config.show_path option like 'add'.
        ['d'] = 'delete',
        ['r'] = 'rename',
        ['y'] = 'copy_to_clipboard',
        ['Y'] = function (state)
          local node = state.tree:get_node()
          -- relative
          local content = node.path:gsub(state.path, ''):sub(2)
          vim.fn.setreg('"', content)
          vim.fn.setreg('1', content)
          vim.fn.setreg('+', content)
        end,
        ['<M-y>'] = function (state)
          local node = state.tree:get_node()
          local content = node.path
          vim.fn.setreg('"', content)
          vim.fn.setreg('1', content)
          vim.fn.setreg('+', content)
        end,
        ['x'] = 'cut_to_clipboard',
        ['p'] = 'paste_from_clipboard',
        ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like 'add':
        -- ['c'] = {
        --  'copy',
        --  config = {
        --    show_path = 'none' -- 'none', 'relative', 'absolute'
        --  }
        --}
        ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like 'add'.
        ['q'] = 'close_window',
        ['R'] = 'refresh',
        ['?'] = 'show_help',
        ['<'] = 'prev_source',
        ['>'] = 'next_source',
        ['['] = function ()
          local width = vim.api.nvim_win_get_width(0) - 3
          print(width)
          vim.api.nvim_win_set_width(0, width)
        end,
        [']'] = function ()
          local width = vim.api.nvim_win_get_width(0) + 3
          vim.api.nvim_win_set_width(0, width)
        end,
      },
      position = 'left',
      width = 37,
    },
  }
end

return N
