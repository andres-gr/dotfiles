local neo_tree_status_ok, neo_tree = pcall(require, 'neo-tree')
if not neo_tree_status_ok then return end

local utils = require 'agr.core.utils'

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
      padding = 0, -- extra padding on left hand side
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
      folder_empty = 'ﰊ',
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
        renamed   = '', -- this can only be used in the git_status source
        -- Status type
        conflict  = '',
        ignored   = '',
        staged    = '',
        unstaged  = '',
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
    filtered_items = {
      always_show = { -- remains visible even if other settings would normally hide it
        '.gitignored',
      },
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
        ['[g'] = 'prev_git_modified',
        [']g'] = 'next_git_modified',
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
    tab_labels = {
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
      nowait = true,
    },
    mappings = {
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
      ['l'] = {
        function (state)
          local cmd = state.commands
          local node = state.tree:get_node()

          cmd.toggle_node(state, node.type ~= 'directory')

          local has_children = node:has_children()

          if has_children and node:is_expanded() then
            vim.fn.feedkeys(utils.key_down)
          end
        end
      },
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
    },
    position = 'left',
    width = 35,
  },
}
