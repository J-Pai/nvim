local whitespace = {}

whitespace.strip_trailing_whitespace = function()
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd([[%s/\s\+$//e]])
  vim.api.nvim_win_set_cursor(0, { r, c })
end

vim.api.nvim_create_autocmd({ 'BufWritePre' },
  { callback = whitespace.strip_trailing_whitespace })

return whitespace
