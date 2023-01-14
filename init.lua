require('plugins')

require('mason').setup()
require('fidget').setup()

-- Theme
require('colorbuddy').colorscheme('gruvbuddy')

-- File explorer
require('tree-config')

-- LSP Configuration
local mason_lspconfig = require('mason-lspconfig')

-- Configure autocomplete after LSP configuration
require('cmp-config')

-- Set up lspconfig.
require('neodev').setup()

-- Set up osc52 support
require('osc52-config')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = {
  clangd = {},
  pylsp = {},
  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
  function(server_name)
    require('lspconfig')[server_name].setup({
      capabilities = capabilities,
      on_attach = require('lsp-config').on_attach,
      settings = servers[server_name],
    })
  end,
})

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'python', 'c', 'cpp', 'lua', 'help' }
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
