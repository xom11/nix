-- Shared variables, replacing hyprlang's `$mod`/`$alt`/`$tab`.
--
-- Must be a MODULE, not globals: each `require`d file is its own Lua chunk and
-- `local` does not cross file boundaries. `require("vars")` resolves because
-- Hyprland sets package.path to the main config's directory, and required files
-- join the config watcher, so editing this triggers a reload like any other.

return {
	mod = "SUPER",
	alt = "ALT",

	-- hyprlang joined modifiers with SPACES; `hl.bind` splits on PLUS. Using
	-- spaces gives "Unknown keysym: ..., did you forget a +?".
	tab = "SUPER + CTRL + SHIFT",
}
