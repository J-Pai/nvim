require('toggleterm').setup({
  open_mapping = [[<c-s>]],
  shade_terminals = false,
  size = function(term)
    if term.direction == "horizontal" then
      return 20
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  direction = 'horizontal',
  persist_size = false,
})

local set_terminal_keymaps = function()
  local opts = { buffer = 0 }

  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*',
  callback = set_terminal_keymaps,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'gitcommit', 'gitrebase', 'gitconfig' },
  callback = function()
    vim.opt.bufhidden = 'delete'
  end
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'tmp*',
  callback = function()
    vim.opt.bufhidden = 'delete'
  end
})

return {}
