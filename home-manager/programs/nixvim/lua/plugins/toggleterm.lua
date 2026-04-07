-- NOTE:
-- 1. auto_scroll = false for AI terminals: fixes bug when scrolling while AI is generating output
-- 2. hidden = true: separates terminal from main list, won't be affected by `open_mapping`
-- 3. Exiting terminal mode with <C-\><C-n>, then ESC again in normal mode to close terminal

local opts = {
	shell = vim.fn.has("win32") == 1 and (vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell") or vim.o.shell,
	direction = "float",
	float_opts = {
		border = "curved",
		height = function()
			return math.floor(vim.o.lines * 0.99)
		end,
		width = function()
			return math.floor(vim.o.columns * 0.99)
		end,
	},
	open_mapping = [[<a-t>]],
}

require("toggleterm").setup(opts)

local Terminal = require("toggleterm.terminal").Terminal
local start_insert = function()
	vim.defer_fn(function()
		vim.cmd("startinsert!")
	end, 50)
end

-- Factory functions for creating terminals
local function make_term(id, term_opts)
	return function()
		Terminal:new(vim.tbl_extend("force", {
			id = id,
			direction = opts.direction,
			float_opts = opts.float_opts,
		}, term_opts or {})):toggle()
	end
end

local function make_tmux_term(id, session)
	return function()
		if vim.fn.executable("tmux") == 0 then
			return vim.notify("tmux is not available", vim.log.levels.ERROR)
		end
		if vim.env.TMUX and vim.trim(vim.fn.system("tmux display-message -p '#S'")) == session then
			return vim.notify("Already in " .. session, vim.log.levels.WARN)
		end
		if os.execute("tmux has-session -t " .. session .. " 2>/dev/null") ~= 0 then
			return vim.notify("Session '" .. session .. "' not found", vim.log.levels.ERROR)
		end
		make_term(id, { cmd = "tmux -u attach -t " .. session })()
	end
end

local function make_ai_term(id, cmd)
	return function()
		-- copy @relative_path and selected text for AI context
		local mode = vim.fn.mode()
		if mode == "v" or mode == "V" or mode == "\22" then
			vim.cmd('normal! "zy')
			local filepath, selected = vim.fn.expand("%:."), vim.fn.getreg("z")
			vim.fn.setreg(
				"+",
				string.format(
					"@%s\n\nLine %d-%d:\n```\n%s\n```\n",
					filepath,
					vim.fn.line("'<"),
					vim.fn.line("'>"),
					selected
				)
			)
    -- copy @relative_path 
		elseif mode == "n" then
			vim.fn.setreg("+", "@" .. vim.fn.expand("%:."))
		end
		Terminal:new({
			id = id,
			cmd = cmd,
			auto_scroll = false,
			on_open = start_insert,
			direction = opts.direction,
			float_opts = opts.float_opts,
		}):toggle()
	end
end

-- Terminal mode keymaps
-- vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("n", "<Esc>", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
	end
end, { desc = "Close terminal in normal mode" })

-- Keymaps
local keymaps = {
	-- terminal
	{ "n", "<leader>tt", make_term(1, { on_open = start_insert }), "ToggleTerm: terminal" },
	-- ai agents
	{ { "n", "v" }, "<leader>aa", make_ai_term(21, "claude --verbose --allow-dangerously-skip-permissions"), "ToggleTerm: claude" },
	{ { "n", "v" }, "<leader>ag", make_ai_term(22, "gemini"), "ToggleTerm: gemini" },
	{ { "n", "v" }, "<leader>ac", make_ai_term(24, "copilot"), "ToggleTerm: copilot" },
	{ { "n", "v" }, "<leader>ao", make_ai_term(25, "opencode"), "ToggleTerm: opencode" },
	-- git
	{ "n", "<leader>gg", make_term(31, { cmd = "lazygit" }), "ToggleTerm: lazygit" },
	{ "n", "<leader>gd", make_term(33, { cmd = "gh-dash" }), "ToggleTerm: gh-dash" },
	{ "n", "<leader>hd", make_term(34, { cmd = "git diff | diffnav" }), "ToggleTerm: git diff" },
  -- tmux
	{ "n", "<leader>to", make_tmux_term(41, "obsidian"), "ToggleTerm: tmux obsidian" },
	{ "n", "<leader>tn", make_tmux_term(42, "nix"), "ToggleTerm: tmux nix" },
}

for _, km in ipairs(keymaps) do
	vim.keymap.set(km[1], km[2], km[3], { desc = km[4] })
end

