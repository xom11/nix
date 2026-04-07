-- Auto-load all opts (skip if plugin not installed)
local opts_dir = vim.fn.stdpath("config") .. "/lua/opts"
for _, file in ipairs(vim.fn.glob(opts_dir .. "/*.lua", false, true)) do
	local name = vim.fn.fnamemodify(file, ":t:r")
	if name ~= "init" then
		local ok, err = pcall(require, "opts." .. name)
		if not ok and not err:match("module .* not found") then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
end
