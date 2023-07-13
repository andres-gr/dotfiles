-- Install your plugins here
return {
  -- Dracula theme
  'Mofiqul/dracula.nvim',

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

  -- Autoclose tags
  'windwp/nvim-ts-autotag',

  -- Context based comments   
  'JoosepAlviste/nvim-ts-context-commentstring',

  -- TS playground
  'nvim-treesitter/playground',

  -- Git commands
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
  },

  -- Git time lapse
  {
    'junkblocker/git-time-lapse',
    event = 'VeryLazy',
  },

  -- Better buffer close
  {
    'famiu/bufdelete.nvim',
    cmd = {
      'Bdelete',
      'Bwipeout',
    },
    event = 'VeryLazy',
  },

  -- Better handle repeat actions
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },

  -- Get extra JSON schemas
  'b0o/SchemaStore.nvim',

  -- Camelcase motion
  {
    'chaoren/vim-wordmotion',
    event = 'VeryLazy',
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

