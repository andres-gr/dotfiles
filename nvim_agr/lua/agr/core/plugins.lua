local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
  print 'Installing packer close and reopen Neovim...'
  vim.cmd [[ packadd packer.nvim ]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

packer.init {
  auto_clean = true,
  -- Have packer use a popup window
  display = {
    open_fn = function ()
      return require 'packer.util'.float { border = 'rounded' }
    end,
  },
}

-- Install your plugins here
local plugins = {
  -- Have packer manage itself
  ['wbthomason/packer.nvim'] = {},

  -- Useful lua functions used by lots of plugins
  ['nvim-lua/plenary.nvim'] = {
    module = 'plenary',
  },

  -- An implementation of the Popup API from vim in Neovim
  ['nvim-lua/popup.nvim'] = {},

  -- Nvim optimizer
  ['lewis6991/impatient.nvim'] = {},

  -- Dracula theme
  ['Mofiqul/dracula.nvim'] = {},

  -- Completions
  ['hrsh7th/nvim-cmp'] = {
    config = function () require 'agr.configs.cmp' end,
    event = 'InsertEnter',
  }, -- The completion plugin

  ['hrsh7th/cmp-buffer'] = {
    after = 'nvim-cmp',
  }, -- buffer completions

  ['hrsh7th/cmp-path'] = {
    after = 'nvim-cmp',
  }, -- path completions

  ['hrsh7th/cmp-cmdline'] = {
    after = 'nvim-cmp',
  }, -- cmdline completions

  ['saadparwaiz1/cmp_luasnip'] = {
    after = 'nvim-cmp',
  }, -- snippet completions

  ['hrsh7th/cmp-nvim-lsp'] = {
    after = 'nvim-cmp',
  }, -- lsp source for cmp

  ['hrsh7th/cmp-nvim-lua'] = {
    after = 'nvim-cmp',
  }, -- lua source for cmp

  -- Snippets
  ['rafamadriz/friendly-snippets'] = {
    opt = true,
  }, -- a bunch of snippets to use

  ['L3MON4D3/LuaSnip'] = {
    module = 'luasnip',
    wants = 'friendly-snippets',
  }, --snippet engine

  -- LSP
  ['williamboman/mason.nvim'] = {
    config = function () require 'agr.configs.lsp' end,
  }, -- simple to use language server installer

  -- mason config bridge
  ['williamboman/mason-lspconfig.nvim'] = {
    after = {
      'mason.nvim',
      'nvim-lspconfig',
    },
    config = function () require 'agr.configs.lsp.mason-lspconfig' end,
  },

  -- Null ls manager
  ['jayp0521/mason-null-ls.nvim'] = {
    after = {
      'mason.nvim',
      'null-ls.nvim',
    },
    config = function () require 'agr.configs.lsp.mason-null-ls' end,
  },

  -- Enable LSP
  ['neovim/nvim-lspconfig'] = {},


  -- LSP symbols
  ['stevearc/aerial.nvim'] = {
    cmd = {
      'AerialInfo',
      'AerialOpen',
      'AerialToggle',
    },
    config = function() require 'agr.configs.aerial' end,
    module = 'aerial',
  },

  ['jose-elias-alvarez/null-ls.nvim'] = {
    config = function () require 'agr.configs.lsp.null-ls' end,
    event = 'BufEnter',
  },

  -- Icons
  ['kyazdani42/nvim-web-devicons'] = {
    module = 'nvim-web-devicons',
  }, -- common icons

  ['onsails/lspkind.nvim'] = {
    module = 'lspkind',
  }, -- LSP icons

  -- Tree explorer
  ['nvim-neo-tree/neo-tree.nvim'] = {
    branch = 'v2.x',
    cmd = 'Neotree',
    config = function () require 'agr.configs.neotree' end,
    module = 'neo-tree',
    requires = {
      {
        'MunifTanjim/nui.nvim',
        module = 'nui',
      },
    },
    setup = function () vim.g.neo_tree_remove_legacy_commands = true end,
  },

  -- Fuzzy finder
  ['nvim-telescope/telescope.nvim'] = {
    cmd = 'Telescope',
    config = function () require 'agr.configs.tele-scope' end,
    module = 'telescope',
  },

  ['nvim-telescope/telescope-fzf-native.nvim'] = {
    after = 'telescope.nvim',
    config = function () require 'telescope'.load_extension('fzf') end,
    run = 'make',
  },

  -- Syntax highlight
  ['nvim-treesitter/nvim-treesitter'] = {
    cmd = {
      'TSDisableAll',
      'TSEnableAll',
      'TSInstall',
      'TSInstallInfo',
      'TSInstallSync',
      'TSUninstall',
      'TSUpdate',
      'TSUpdateSync',
    },
    config = function () require 'agr.configs.treesitter' end,
    event = {
      'BufNewFile',
      'BufRead',
    },
    run = ':TSUpdate',
  },

  ['p00f/nvim-ts-rainbow'] = {
    after = 'nvim-treesitter',
  }, -- Rainbow parenthesis highlight

  ['windwp/nvim-ts-autotag'] = {
    after = 'nvim-treesitter',
  }, -- Autoclose tags

  ['windwp/nvim-autopairs'] = {
    config = function () require 'agr.configs.autopairs' end,
    event = 'InsertEnter',
  }, -- Auto insert matching pair

  ['JoosepAlviste/nvim-ts-context-commentstring'] = {
    after = 'nvim-treesitter',
  }, -- Context based comments

  -- Commenting
  ['numToStr/Comment.nvim'] = {
    config = function () require 'agr.configs.comment' end,
    keys = {
      'gc',
      'gb',
      'g<',
      'g>',
    },
    module = {
      'Comment',
      'Comment.api',
    },
  },

  -- Git integration
  ['lewis6991/gitsigns.nvim'] = {
    config = function () require 'agr.configs.git-signs' end,
    event = 'BufEnter',
  },

  -- Buffer management
  ['akinsho/bufferline.nvim'] = {
    config = function () require 'agr.configs.buffer-line' end,
    event = 'UIEnter',
  }, -- Buffers like tabs

  ['famiu/bufdelete.nvim'] = {
    cmd = {
      'Bdelete',
      'Bwipeout',
    },
  }, -- Better buffer close

  -- Handle surround characters
  ['kylechui/nvim-surround'] = {
    config = function () require 'agr.configs.surround' end,
    event = 'BufEnter',
    tag = '*',
  },

  -- Better handle repeat actions
  ['tpope/vim-repeat'] = {
    event = 'BufEnter',
  },

  -- Indent detection
  ['Darazaki/indent-o-matic'] = {
    config = function () require 'agr.configs.indent' end,
    event = 'BufReadPost',
  },

  -- Notification Enhancer
  ['rcarriga/nvim-notify'] = {
    config = function() require 'agr.configs.notify' end,
    event = 'UIEnter',
  },

  -- Neovim UI Enhancer
  ['stevearc/dressing.nvim'] = {
    config = function() end,
    event = 'UIEnter',
  },

  -- Color highlighting
  ['NvChad/nvim-colorizer.lua'] = {
    config = function() require 'agr.configs.colorizer' end,
    event = {
      'BufNewFile',
      'BufRead',
    },
  },

  -- Indentation
  ['lukas-reineke/indent-blankline.nvim'] = {
    config = function() require 'agr.configs.indent-line' end,
    event = 'BufRead',
  },

  -- Smooth escaping
  ['max397574/better-escape.nvim'] = {
    config = function() require 'agr.configs.escape' end,
    event = 'InsertCharPre',
  },

  -- Get extra JSON schemas
  ['b0o/SchemaStore.nvim'] = {
    module = 'schemastore',
  },

  -- Keymaps popup
  ['folke/which-key.nvim'] = {
    config = function() require 'agr.configs.which-key' end,
    event = 'BufWinEnter',
    module = 'which-key',
  },

  -- Start screen
  ['goolord/alpha-nvim'] = {
    cmd = 'Alpha',
    config = function() require 'agr.configs.alpha' end,
    module = 'alpha',
  },

  -- Status line
  ['rebelot/heirline.nvim'] = {
    config = function () require 'agr.configs.heir-line' end,
  },

  -- Highlight under cursor
  ['RRethy/vim-illuminate'] = {
    config = function () require 'agr.configs.illuminate' end,
  },
}

-- Install your plugins here
return packer.startup {
  function (use)
    for key, plugin in pairs(plugins) do
      if type(key) == 'string' and not plugin[1] then
        plugin[1] = key
      end

      use(plugin)
    end

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
      require 'packer'.sync()
    end
  end,
}

