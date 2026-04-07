-- Auto-load all plugin configs (skip if plugin not installed)
local dir = vim.fn.stdpath("config") .. "/lua/plugins"
for _, file in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
	local name = vim.fn.fnamemodify(file, ":t:r")
	if name ~= "init" then
		local ok, err = pcall(require, "plugins." .. name)
		if not ok and not err:match("module .* not found") then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
end
