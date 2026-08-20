-- Force English in Normal mode, restore the IME in Insert mode.
--
-- Was extras/language-nvim.lua here. Worth publishing because with an external
-- Vietnamese IME (GoNhanh/EVKey/OpenKey) `vi` and `en` are the SAME macOS input
-- source `com.apple.keylayout.ABC` -- what differs is whether the IME process is
-- on, which macOS does not expose. Plugins that key off input-source IDs cannot
-- see it; `tongue` can.
--
-- No OS guard needed: on a host with neither tool the plugin resolves to nil and
-- stays quiet. `:checkhealth tongue` reports which state it is in.
--
-- `backend` is declared EXPLICITLY, which is load-bearing: auto-detect bails out
-- when it sees an SSH session, and every herdr pane on macmini inherits
-- `SSH_CONNECTION` forever because the server was started from `ssh rog ->
-- macmini`. That variable is a fossil of how the server booted, not a statement
-- about who is typing. An explicit backend wins over that guard.
--
-- The machine running nvim is not always the machine holding the keyboard: under
-- `herdr --remote macmini`, rog's fcitx5 converts keys before the bytes cross
-- SSH, so a local `tongue` call would switch the wrong machine. `bin/ime-route`
-- normalises `tongue` and `fcitx5-remote` onto one `en|vi|zh` vocabulary and
-- routes to the right host -- an extension point the plugin designs for, not a
-- workaround. A missing file falls back to the old behaviour.
--
-- Upstream offers two shapes for an environment-dependent backend: a
-- self-routing script, or calling `setup()` again whenever the answer changes.
-- The script wins on correctness, not convenience: normalised tokens keep their
-- meaning across machines, while the `setup()` route must forget the remembered
-- layout on every call. Cost measured at 34 ms per call, on an async path
-- nobody waits for.
local route = vim.fn.expand("~/.nix/home-manager/programs/nvim/bin/ime-route")
-- Gate on `ime-route` existing, NOT on `has("mac")`: the script is what knows
-- which tool this machine has. Gating by OS leaves rog (no `tongue`) with a nil
-- backend, the SSH guard fires, and the plugin sits silent with no signal.
local backend = nil
if vim.fn.executable(route) == 1 then
	backend = {
		english = "en",
		get = { route, "get" },
		set = { route, "set" },
		-- Both branches say `unknown` when state is unreadable: `tongue` when
		-- live state matches no mode, ime-route when `fcitx5-remote -n` returns
		-- empty because nothing holds an input context.
		unknown = "unknown",
		tokens = { "en", "vi", "zh" },
	}
elseif vim.fn.has("mac") == 1 and vim.fn.executable("tongue") == 1 then
	backend = "tongue"
end

-- `restore_on_unfocus` is off upstream; on here because nvim almost always sits
-- in a herdr pane and the IME is machine-global state -- without it, "English in
-- Normal mode" follows you into every other tab with no event to undo it.
-- Measured: switching pane or tab does fire FocusLost/FocusGained (herdr
-- forwards mode 1004), but `<C-z>` and `:q` fire nothing, so those are handled
-- synchronously via VimSuspend/VimLeavePre. That costs `:q` about 200 ms.
vim.pack.add({ { src = "https://github.com/xom11/tongue.nvim" } }, { load = true, confirm = false })
require("tongue").setup({ backend = backend, restore_on_unfocus = true })
