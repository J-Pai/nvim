local osc52 = require('osc52')

vim.keymap.set('n', '<leader>c', osc52.copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('x', '<leader>c', osc52.copy_visual)

return osc52
