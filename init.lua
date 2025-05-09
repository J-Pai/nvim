require('plugins')

require('mason').setup()
require('fidget').setup()

-- Set up terminal
require('terminal')

-- Theme
require('colorbuddy').colorscheme('gruvbuddy')
require('lualine').setup {
  options = { theme = 'wombat' }
}

-- LSP Configuration
local mason_lspconfig = require('mason-lspconfig')

-- Configure autocomplete after LSP configuration
require('cmp-config')

-- Set up lspconfig.
require('neodev').setup()

-- Set up osc52 support
require('osc52-config')

require("trouble").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = {
  clangd = {},
  pylsp = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  rust_analyzer = {
    cargo = {
      buildScripts = {
        enable = true,
      },
    },
  },
}

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup({
      capabilities = capabilities,
      on_attach = require('lsp-config').on_attach,
      settings = servers[server_name],
    })
  end,
}

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'python', 'c', 'cpp', 'lua', 'typescript', 'rust' },
  auto_install = true,
  highlight = { enable = true },
}

-- General Configuration
vim.opt.updatetime = 250

vim.opt.clipboard = 'unnamedplus' -- shared system clipboard

vim.opt.colorcolumn = { 80 }
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = 'black' })
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NonText', { bg = 'none' })

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.list = true
vim.opt.listchars = { tab = '> ', trail = '·', eol = '¬' }
Whitespace = require('whitespace')

vim.api.nvim_set_keymap('v', 'p', '"_dP', { noremap = true })
vim.opt.hidden = false
