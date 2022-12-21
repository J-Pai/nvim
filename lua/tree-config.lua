local tree = require('nvim-tree')

vim.g.loaded_netrw = 1;
vim.g.loaded_netrwPlugin = 1;

vim.opt.termguicolors = true

tree.setup()

tree.setup({
    sort_by = 'case_sensitive',
    view = {
      mappings = {
        list = {
          { key = 'u', action = 'dir_up' },
        },
      },
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
  })

return tree
