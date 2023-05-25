local tree = require('nvim-tree')

vim.g.loaded_netrw = 1;
vim.g.loaded_netrwPlugin = 1;

vim.opt.termguicolors = true

local function on_attach(_)
end

tree.setup({
  sort_by = 'case_sensitive',
  on_attach = on_attach,
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

return tree
