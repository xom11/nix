-- Detect SSH: check shell env first, then tmux session env (for stale panes)
local is_ssh = vim.env.SSH_TTY or vim.env.SSH_CLIENT or vim.env.SSH_CONNECTION
if not is_ssh and vim.env.TMUX then
	local out = vim.fn.system("tmux show-environment SSH_CONNECTION 2>/dev/null")
	is_ssh = vim.v.shell_error == 0 and out:match("SSH_CONNECTION=")
end

-- A herdr pane never carries SSH_*: panes are spawned by the herdr server, and
-- it is the attached client -- local, or over ssh, and swappable on every
-- reattach -- that owns the clipboard. So SSH is the wrong question here; the
-- pane cannot know, and the answer changes under it. herdr routes OSC 52 to
-- whichever client is currently attached, which is right either way.
local is_herdr = vim.env.HERDR_PANE_ID or vim.env.HERDR_ENV

if not (is_ssh or is_herdr) then
	return
end

-- tmux: use tmux paste buffer with OSC 52 passthrough (-w)
if vim.env.TMUX then
	local copy = { "tmux", "load-buffer", "-w", "-" }
	local paste = { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
	vim.g.clipboard = {
		name = "tmux",
		copy = { ["+"] = copy, ["*"] = copy },
		paste = { ["+"] = paste, ["*"] = paste },
		cache_enabled = 0,
	}
-- herdr without tmux: OSC 52 out, but never the OSC 52 read query -- herdr has
-- no client-to-pane path and answers it with nothing, so osc52.paste() would
-- stall 1s + 9s on every paste. Serve "+ from what we last copied; text copied
-- on the client machine still arrives through the terminal's own paste.
elseif is_herdr then
	local write = require("vim.ui.clipboard.osc52").copy("+")
	local cache = { { "" }, "v" }
	local function copy(lines, regtype)
		cache = { lines, regtype }
		write(lines)
	end
	local function paste()
		return cache
	end
	vim.g.clipboard = {
		name = "herdr OSC 52",
		copy = { ["+"] = copy, ["*"] = copy },
		paste = { ["+"] = paste, ["*"] = paste },
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
