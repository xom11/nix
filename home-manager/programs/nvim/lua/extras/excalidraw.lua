-- An empty .excalidraw file fails the PWA's JSON.parse on open -- prefill
-- a minimal valid scene so a freshly created (or empty) file opens right away.
local function fill(buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"{",
		'  "type": "excalidraw",',
		'  "version": 2,',
		'  "source": "nvim",',
		'  "elements": [],',
		'  "appState": {',
		'    "gridSize": null,',
		'    "viewBackgroundColor": "#ffffff"',
		"  },",
		'  "files": {}',
		"}",
	})
end

vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.excalidraw",
	callback = function(args)
		fill(args.buf)
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*.excalidraw",
	callback = function(args)
		if vim.api.nvim_buf_line_count(args.buf) == 1 and vim.api.nvim_buf_get_lines(args.buf, 0, 1, true)[1] == "" then
			fill(args.buf)
		end
	end,
})
