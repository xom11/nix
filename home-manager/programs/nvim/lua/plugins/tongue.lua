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
-- Same lesson one level down: gate on the tool, not the OS. a14 carries
-- `tongue.exe`, but auto-detect's Windows chain knows only `im-select.exe` --
-- which reads a locale ID, and with VKey `vi` and `en` are the SAME locale, so
-- it runs and changes nothing you can see. Measured on a14 20/08/2026:
-- `active via im-select.exe`, `reads back "0"`, and the plugin's own note says
-- exactly that. `tongue` sees VKey; declaring it here is what picks it.
--
-- Only helps a LOCAL nvim there: over SSH, Windows puts the session in session 0
-- and `tongue.exe` refuses with "khong voi toi duoc desktop tuong tac" -- VKey
-- lives in session 1.
--
-- That wall has since been crossed, upstream: tongue 74be163 adds `tongue agent`,
-- a process living in the desktop session that listens on `\\.\pipe\tongue-<user>`
-- -- a namespace that is NOT per-session -- and every session-0 call forwards into
-- it. Deployed on a14 as the `TongueAgent` task; `ssh a14 tongue vi` works, 5/5.
--
-- `ime-route` still refuses a14, and the reason is now the WIRE rather than the
-- wall: leaving Insert costs TWO sequential backend calls (this plugin sets
-- `observe` on the way out, which skips the fast path), and one ssh leg to a14 is
-- 452 ms multiplexed / 829 ms not. The pipe hop is free; the two ssh legs are not
-- -- ~900 ms per <Esc> against a 150-400 ms window. So the host is refused BY NAME
-- before the connection opens (`SKIP_HOSTS`, escape hatch `IME_ROUTE_SKIP=`), and
-- `ime-route where` spells that out. Switch modes on a14 itself with Cap+Q/W/E.
elseif vim.fn.executable("tongue") == 1 then
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
