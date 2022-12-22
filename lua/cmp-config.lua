local cmp = require('cmp')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))

  if col ~= 0 then
    return false
  end

  local more_lines = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    :sub(col, col)
    :match("%s")

  return more_lines == nil
end

local tab_select = function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
  end
end

local shift_tab_select = function()
  if cmp.visible() then
    cmp.select_prev_item()
  end
end

cmp.setup({
    snippet = {
      expand = function(args)
        require('snippy').expand_snippet(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(tab_select, {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(shift_tab_select, {'i', 's'}),
      }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
      }, {
        { name = 'buffer' },
      }),
  })

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' },
      }, {
        { name = 'buffer' },
      }),
  })

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'cmdline' },
      }),
  })

return cmp
