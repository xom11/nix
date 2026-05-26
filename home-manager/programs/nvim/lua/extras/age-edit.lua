-- Transparent edit of *.age files.
--   BufReadCmd : decrypt via `age -d -i <identity>` into the buffer.
--   BufWriteCmd: encrypt the buffer via `age -R <recipients>` back to disk.
-- Recipients and identity come from files rendered by the agenix HM module
-- (~/.config/agenix/{recipients,identity}), so a single Nix source of truth
-- (home-manager/services/agenix/keys.nix) governs both the CLI and nvim.

local identity_file = vim.fn.expand("~/.config/agenix/identity")
local recipients_file = vim.fn.expand("~/.config/agenix/recipients")

local function read_identity()
	local fd = io.open(identity_file, "r")
	if not fd then
		return vim.fn.expand("~/.ssh/id_ed25519")
	end
	local line = fd:read("l") or ""
	fd:close()
	return vim.fn.expand(line)
end

local group = vim.api.nvim_create_augroup("AgeTransparent", { clear = true })

-- Defining `BufReadCmd` replaces the normal read pipeline, so `BufReadPre`
-- does NOT fire — opts must be set inline in each handler.
-- `backup`/`writebackup` are global-only options, but `BufWriteCmd`
-- replaces the normal write pipeline entirely, so neither applies here.
local function disable_persistence()
	vim.opt_local.swapfile = false
	vim.opt_local.undofile = false
	vim.bo.buftype = "acwrite"
end

vim.api.nvim_create_autocmd("BufNewFile", {
	group = group,
	pattern = "*.age",
	callback = disable_persistence,
})

-- Decrypt on open.
vim.api.nvim_create_autocmd("BufReadCmd", {
	group = group,
	pattern = "*.age",
	callback = function(args)
		disable_persistence()
		local path = vim.fn.fnamemodify(args.match, ":p")
		local id = read_identity()
		local out = vim.fn.systemlist({ "age", "-d", "-i", id, path })
		if vim.v.shell_error ~= 0 then
			vim.notify("age decrypt failed:\n" .. table.concat(out, "\n"), vim.log.levels.ERROR)
			return
		end
		vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
		vim.bo.modified = false
		-- Pick a filetype from the inner extension if there is one
		-- (e.g. "foo.sh.age" -> sh). Falls through silently otherwise.
		local inner = path:gsub("%.age$", "")
		local ft = vim.filetype.match({ filename = inner })
		if ft then
			vim.bo.filetype = ft
		end
	end,
})

-- Encrypt on save.
vim.api.nvim_create_autocmd("BufWriteCmd", {
	group = group,
	pattern = "*.age",
	callback = function(args)
		local path = vim.fn.fnamemodify(args.match, ":p")
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local content = table.concat(lines, "\n")
		if #lines > 0 then
			content = content .. "\n"
		end

		vim.fn.system({ "age", "-R", recipients_file, "-o", path }, content)

		if vim.v.shell_error ~= 0 then
			vim.notify("age encrypt failed", vim.log.levels.ERROR)
			return
		end
		vim.bo.modified = false
	end,
})
