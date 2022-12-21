require('plugins')

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

-- General Configuration
vim.opt.clipboard = 'unnamedplus' -- shared system clipboard

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.list = true
vim.opt.listchars = { tab = '> ', trail = '·', eol = '¬' }
whitespace = require('whitespace')

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
