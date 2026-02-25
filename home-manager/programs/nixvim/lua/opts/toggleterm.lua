local shell_cmd = vim.o.shell
if vim.fn.has("win32") == 1 then
	if vim.fn.executable("pwsh") == 1 then
		shell_cmd = "pwsh"
	else
		shell_cmd = "powershell"
	end
end

local opts = {
	shell = shell_cmd,
	direction = "float",
	float_opts = {
		border = "curved",
		height = function()
			return math.floor(vim.o.lines * 0.9)
		end,
		width = function()
			return math.floor(vim.o.columns * 0.9)
		end,
	},
	open_mapping = [[<a-t>]],
}


return opts
