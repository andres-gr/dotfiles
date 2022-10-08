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
  vim.cmd [[packadd packer.nvim]]
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

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function ()
      return require 'packer.util'.float { border = 'rounded' }
    end,
  },
}

-- Install your plugins here
return packer.startup(function (use)
  -- My plugins here
  use 'wbthomason/packer.nvim' -- Have packer manage itself
  use {
    'nvim-lua/plenary.nvim' ,
    module = 'plenary',
  }-- Useful lua functions used by lots of plugins

  use 'nvim-lua/popup.nvim' -- An implementation of the Popup API from vim in Neovim
  use 'lewis6991/impatient.nvim' -- Nvim optimizer

  -- Dracula theme
  use 'Mofiqul/dracula.nvim'

  -- Completions
  use {
    'hrsh7th/nvim-cmp',
    config = function () require 'agr.configs.cmp' end,
    event = 'InsertEnter',
  } -- The completion plugin

  use {
    'hrsh7th/cmp-buffer',
    after = 'nvim-cmp',
  } -- buffer completions

  use {
    'hrsh7th/cmp-path',
    after = 'nvim-cmp',
  } -- path completions

  use {
    'hrsh7th/cmp-cmdline',
    after = 'nvim-cmp',
  } -- cmdline completions

  use {
    'saadparwaiz1/cmp_luasnip',
    after = 'nvim-cmp',
  } -- snippet completions

  use {
    'hrsh7th/cmp-nvim-lsp',
    after = 'nvim-cmp',
  } -- lsp source for cmp

  use {
    'hrsh7th/cmp-nvim-lua',
    after = 'nvim-cmp',
  } -- lua source for cmp

  -- Snippets
  use {
    'rafamadriz/friendly-snippets',
    opt = true,
  } -- a bunch of snippets to use

  use {
    'L3MON4D3/LuaSnip',
    module = 'luasnip',
    wants = 'friendly-snippets',
  } --snippet engine

  -- LSP
  use {
    'williamboman/mason.nvim',
    config = function () require 'agr.configs.lsp' end,
  } -- simple to use language server installer

  use {
    'williamboman/mason-lspconfig.nvim',
    after = {
      'mason.nvim',
      'nvim-lspconfig',
    },
    config = function () require 'agr.configs.lsp.mason-lspconfig' end,
  } -- mason config bridge

  use 'neovim/nvim-lspconfig' -- enable LSP

  -- Icons
  use {
    'kyazdani42/nvim-web-devicons',
    module = 'nvim-web-devicons',
  } -- common icons

  use {
    'onsails/lspkind.nvim',
    module = 'lspkind',
  } -- LSP icons

  -- Tree explorer
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    cmd = 'Neotree',
    config = function () require 'agr.configs.neo-tree' end,
    module = 'neo-tree',
    requires = {
      {
        'MunifTanjim/nui.nvim',
        module = 'nui',
      },
    },
    setup = function () vim.g.neo_tree_remove_legacy_commands = true end,
  }

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function () require 'agr.configs.telescope' end,
    module = 'telescope',
  }

  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    after = 'telescope.nvim',
    config = function () require 'telescope'.load_extension('fzf') end,
    run = 'make',
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require 'packer'.sync()
  end
end)

