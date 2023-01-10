-- Install your plugins here
return {
  -- Dracula theme
  'Mofiqul/dracula.nvim',

  -- Useful lua functions used by lots of plugins
  'nvim-lua/plenary.nvim',

  -- An implementation of the Popup API from vim in Neovim
  'nvim-lua/popup.nvim',

  -- Icons
  'kyazdani42/nvim-web-devicons',

  -- Component library
  'MunifTanjim/nui.nvim',

  -- Rainbow parenthesis highlight
  'mrjones2014/nvim-ts-rainbow',

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
}

