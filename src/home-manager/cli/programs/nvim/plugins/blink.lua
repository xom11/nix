local blink = require("blink.cmp")

blink.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  
  mapping = blink.mapping.preset.insert({
    ["<C-b>"] = blink.mapping.scroll_docs(-4),
    ["<C-f>"] = blink.mapping.scroll_docs(4),
    ["<C-Space>"] = blink.mapping.complete(),
    ["<C-e>"] = blink.mapping.abort(),
    ["<CR>"] = blink.mapping.confirm({ select = true }),
    ["<C-k>"] = blink.mapping.select_prev_item(),
    ["<C-j>"] = blink.mapping.select_next_item(),
  }),
  
  sources = {
    blink.source.lsp,
    blink.source.path,
    blink.source.buffer,
    blink.source.snippets,
    blink.source.cmdline, 
  },
})