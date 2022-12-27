local fn = vim.fn

local ensure_packer = function()
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
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

local install_path = fn.expand('$HOME/.local/luals/')
local lua_exe = install_path..'bin/lua-language-server'
local lua_lsp_version = '3.6.4'

local ensure_lua_lsp = function()
  local url = 'https://github.com/sumneko/lua-language-server/releases/download/'..lua_lsp_version..'/'
  local tar = 'lua-language-server-'..lua_lsp_version..'-linux-x64.tar.gz'
  if fn.empty(fn.glob(lua_exe)) > 0 then
    fn.system({ 'mkdir', '-p', install_path })
    fn.system({ 'wget',  url..tar, '-P', install_path })
    fn.system({ 'tar', '-C', install_path, '-xvf', install_path..'/'..tar })
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
local lua_lsp_boostrap = ensure_lua_lsp()

local packer = require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- nvim LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'j-hui/fidget.nvim',
      'folke/neodev.nvim'
    },
  }
  use 'anott03/nvim-lspinstall'
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
  use { -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }
  use 'sheerun/vim-polyglot'
  use 'tjdevries/colorbuddy.nvim'
  use 'tjdevries/gruvbuddy.nvim'

  -- File explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

return packer
