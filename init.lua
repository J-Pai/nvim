local plugins = require('plugins')

-- Theme
require('colorbuddy').colorscheme('gruvbuddy')

-- File explorer
require('tree-config')

-- LSP Configuration
local lsp_config = require('lspconfig')
lsp_config.pylsp.setup{}
lsp_config.luau_lsp.setup{}

-- Configure autocomplete after LSP configuration
require('cmp-config')

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['pylsp'].setup({
    capabilities = capabilities,
  })

require('lspconfig')['clangd'].setup({
    capabilities = capabilities,
  })

require('neodev').setup()
require('lspconfig')['sumneko_lua'].setup({
    capabilities = capabilities,
    cmd = { plugins and plugins.lua_exe or '' },
    settings = { Lua = { completion = { callSnippet = "Replace" } } },
  })

-- General Configuration
vim.opt.clipboard = 'unnamedplus' -- shared system clipboard

vim.opt.colorcolumn = { 80 }
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = 'black' })

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.list = true
vim.opt.listchars = { tab = '> ', trail = '·', eol = '¬' }
Whitespace = require('whitespace')

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
