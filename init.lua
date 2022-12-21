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

