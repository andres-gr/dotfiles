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
  -- {
  --   'nvim-lua/popup.nvim',
  --   lazy = true,
  -- },

  -- Icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
  },

  -- Git commands
  {
    'tpope/vim-fugitive',
    cmd = {
      'G',
      'GBrowse',
      'Gcd',
      'Gclog',
      'GDelete',
      'Gdiffsplit',
      'Gdrop',
      'Gedit',
      'Ghdiffsplit',
      'Git',
      'Glcd',
      'Gllog',
      'Glrep',
      'GMove',
      'Gpedit',
      'Gread',
      'GRemove',
      'GRename',
      'Grep',
      'Gsplit',
      'Gtabedit',
      'GUnlink',
      'Gvdiffsplit',
      'Gvsplit',
      'Gwq',
      'Gwrite',
    },
    lazy = true,
  },

  -- Git time lapse
  {
    'junkblocker/git-time-lapse',
    cmd = 'GitTimeLapse',
    lazy = true,
  },

  -- Git Diff views
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewFileHistory',
    },
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
    event = {
      'BufNewFile',
      'BufReadPost',
    },
    lazy = true,
  },

  -- Get extra JSON schemas
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
  },

  -- Camelcase motion
  {
    'chaoren/vim-wordmotion',
    event = {
      'BufNewFile',
      'BufReadPost',
    },
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
