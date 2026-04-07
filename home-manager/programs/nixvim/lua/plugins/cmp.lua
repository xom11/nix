local cmp = require("cmp")
local luasnip = require("luasnip")
local opts = {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "luasnip" },
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "buffer" },
		-- { name = "render-markdown" },
	},
	mapping = {
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.get_selected_entry() then
				cmp.confirm({ select = true })
			else
				fallback()
			end
		end),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false }),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-e>"] = cmp.mapping.close(),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
			elseif require("copilot.suggestion").is_visible() then
				require("copilot.suggestion").accept()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
			else
				fallback()
			end
		end, { "i", "s" }),
	},
}

local cmdline = {
	[":"] = {
		-- NOTE similar to zsh
		-- - Up/Down to navigate history when no selection
		-- - Up/Down to navigate completion when selection
		-- - Tab/S-Tab to navigate completion
		mapping = cmp.mapping.preset.cmdline({
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end, { "c" }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "c" }),

			["<Up>"] = cmp.mapping(function(fallback)
				if cmp.visible() and cmp.get_selected_entry() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "c" }),

			["<Down>"] = cmp.mapping(function(fallback)
				if cmp.visible() and cmp.get_selected_entry() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "c" }),

			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.visible() and cmp.get_selected_entry() then
					cmp.confirm({ select = false })
				else
					fallback()
				end
			end, { "c" }),
		}),
		sources = {
			{ name = "path" },
			{ name = "cmdline" },
		},
	},
}

cmp.setup(opts)
cmp.setup.cmdline(":", cmdline[":"])
