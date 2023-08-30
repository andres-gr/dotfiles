-- Install your plugins here
return {
  -- Dracula theme
  {
    'Mofiqul/dracula.nvim',
    priority = 1000,
  },

  -- Useful lua functions used by lots of plugins
  {
    'nvim-lua/plenary.nvim',
    lazy = true,
  },

  -- An implementation of the Popup API from vim in Neovim
  'nvim-lua/popup.nvim',

  -- Icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
  },

  -- Git commands
  {
    'tpope/vim-fugitive',
    lazy = true,
  },

  -- Git time lapse
  {
    'junkblocker/git-time-lapse',
    lazy = true,
  },

  -- Git Diff views
  {
    'sindrets/diffview.nvim',
    lazy = true,
  },

  -- Better buffer close
  {
    'famiu/bufdelete.nvim',
    cmd = {
      'Bdelete',
      'Bwipeout',
    },
    lazy = true,
  },

  -- Better handle repeat actions
  {
    'tpope/vim-repeat',
    lazy = true,
  },

  -- Get extra JSON schemas
  'b0o/SchemaStore.nvim',

  -- Camelcase motion
  {
    'chaoren/vim-wordmotion',
    lazy = true,
  },

   -- Session management
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {
      options = {
        'buffers',
        'curdir',
        'tabpages',
        'winsize',
        'help',
        'globals',
        'skiprtp',
      },
    },
  },
}
