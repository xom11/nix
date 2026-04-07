-- Auto-load all plugin configs (skip if plugin not installed)
-- Find the directory of this file (works across all configs via rtp)
local source = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fn.fnamemodify(source, ":h")
for _, file in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
	local name = vim.fn.fnamemodify(file, ":t:r")
	if name ~= "init" then
		local ok, err = pcall(require, "plugins." .. name)
		if not ok and not err:match("module .* not found") then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
end
