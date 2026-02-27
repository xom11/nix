local vim = vim
local en = 0
local vn = 1
local last_layout = en
local sysname = vim.loop.os_uname().sysname
local is_mac = sysname == "Darwin" and vim.fn.executable("gn") == 1

if not is_mac then
  return {
    switch_to_vietnamese = function() end,
    switch_to_english = function() end,
  }
end

local function set_layout(layout)
	vim.fn.jobstart("gn " .. layout, { detach = true })
end

local function get_layout(callback)
	vim.fn.jobstart("gn", {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local result = table.concat(data, "")
			callback(tonumber(result:match("%d")) or en)
		end,
	})
end

local function switch_to_vietnamese()
	set_layout(vn)
end

local function switch_to_english()
	set_layout(en)
end

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		get_layout(function(layout)
			last_layout = layout
		end)
		set_layout(en)
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		set_layout(last_layout)
	end,
})

vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		if vim.fn.mode() == "i" then
			set_layout(last_layout)
		else
			set_layout(en)
		end
	end,
})

return {
	switch_to_vietnamese = switch_to_vietnamese,
	switch_to_english = switch_to_english,
}
