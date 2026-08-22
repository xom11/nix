-- Shared variables, replacing hyprlang's `$mod`/`$alt`/`$tab`.
-- Must be a MODULE: `local` does not cross file boundaries.
-- Modifiers joined with SPACES — `hl.bind` splits on PLUS; hyprlang-style
-- "SUPER CTRL SHIFT" gives "Unknown keysym".

return {
	mod = "SUPER",
	alt = "ALT",
	tab = "SUPER + CTRL + SHIFT",
}
