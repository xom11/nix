return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-cmdline", -- Cần thiết cho cấu hình cmdline (:) của bạn
		"hrsh7th/cmp-emoji",
	},
	---@param opts cmp.ConfigSchema
	opts = function(_, opts)
		local cmp = require("cmp")

		-- 1. Cấu hình Sources (Nguồn gợi ý)
		opts.sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "buffer" },
			{ name = "render-markdown" }, -- Nguồn từ nixvim của bạn
		})

		-- 2. Cấu hình Mapping (Phím tắt)
		opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
			-- Phím Enter (<CR>)
			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.get_selected_entry() then
					cmp.confirm({ select = true })
				else
					fallback()
				end
			end),

			-- Phím mũi tên
			["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false }),
			["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false }),

			-- Các phím điều hướng khác
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-e>"] = cmp.mapping.close(),
			["<C-f>"] = cmp.mapping.scroll_docs(4),

			-- Phím Tab (Tích hợp Copilot như trong Nix của bạn)
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
				elseif
					-- Kiểm tra nếu có copilot và đang hiển thị suggestion
					package.loaded["copilot"] and require("copilot.suggestion").is_visible()
				then
					require("copilot.suggestion").accept()
				else
					fallback()
				end
			end, { "i", "s" }),
		})

		-- 3. Cấu hình cho Cmdline (Dòng lệnh :)
		-- Vì đây là hàm setup riêng, ta gọi trực tiếp sau khi nvim-cmp load
		cmp.setup.cmdline(":", {
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
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
