-- Detect SSH: check shell env first, then tmux session env (for stale panes)
local is_ssh = vim.env.SSH_TTY or vim.env.SSH_CLIENT or vim.env.SSH_CONNECTION
if not is_ssh and vim.env.TMUX then
	local out = vim.fn.system("tmux show-environment SSH_CONNECTION 2>/dev/null")
	is_ssh = vim.v.shell_error == 0 and out:match("SSH_CONNECTION=")
end

if not is_ssh then
	return
end

-- SSH + tmux: use tmux paste buffer with OSC 52 passthrough (-w)
if vim.env.TMUX then
	local copy = { "tmux", "load-buffer", "-w", "-" }
	local paste = { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
	vim.g.clipboard = {
		name = "tmux",
		copy = { ["+"] = copy, ["*"] = copy },
		paste = { ["+"] = paste, ["*"] = paste },
		cache_enabled = 0,
	}
-- SSH without tmux: direct OSC 52
else
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
	}
end
