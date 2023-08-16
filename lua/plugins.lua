local fn = vim.fn

local ensure_packer = function()
  if os.getenv("PVIM") then
    return true
  end
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim', install_path
    })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local packer = require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'j-hui/fidget.nvim',
    tag = 'legacy',
  }

  -- nvim LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim'
    },
  }


  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    }
  }

  -- themes and syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }
  use 'google/vim-maktaba'
  use 'bazelbuild/vim-bazel'

  -- Additional text objects via treesitter
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  use 'tpope/vim-sleuth'
  use 'tpope/vim-fugitive'

  use 'tjdevries/colorbuddy.nvim'
  use 'tjdevries/gruvbuddy.nvim'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- File explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
  }

  -- Copy over SSH
  use { 'ojroques/nvim-osc52' }

  -- Terminal
  use {
    'akinsho/toggleterm.nvim',
    tag = '*',
  }
  use {
    'mhinz/neovim-remote',
    run = function()
      fn.system({ 'python3', '-m', 'pip', 'install', 'neovim-remote' })
    end,
  }

  if not os.getenv("PVIM") and packer_bootstrap then
    require('packer').sync()
  end
end)

return packer
