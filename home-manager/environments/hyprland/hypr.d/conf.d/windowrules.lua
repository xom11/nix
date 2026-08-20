-- Every new TILING window goes to the lowest-numbered EMPTY workspace. sway does
-- this with a script instead; it has no equivalent rule.
--
-- The point is that beckon is focus-or-launch: the first press LAUNCHES, so the
-- new window lands on its own workspace; later presses FOCUS it and the
-- compositor follows. Net effect: one app per workspace, navigated by app key
-- rather than workspace number.
--
-- SYNTAX: `match` holds the conditions, every other top-level key is an ACTION.
-- Both halves are name-checked into `hyprctl configerrors`. `name` is optional
-- but worth setting -- rules are identified BY NAME, so a named rule is REPLACED
-- on reload instead of accumulating.
--
-- `emptym` is the first empty workspace on the current MONITOR. Not `emptynm`:
-- the `n` makes it pick the next empty one AFTER the current workspace, so the
-- session's first window skips to 2 and workspace 1 disappears
-- (hyprwm/Hyprland#7153).
--
-- SCOPE WARNING: `--verify-config` checks NAMES, not VALUES -- `workspace
-- emptyZZZ` also returns `config ok`. So the value `emptym` and the dialog
-- behaviour of `float = false` are unproven here and need checking at the machine.
--
-- `float = false` keeps dialogs (Save As, file pickers, popups) in place.
hl.window_rule({
	name = "new-window-to-empty-workspace",
	match = { class = ".*", float = false },
	workspace = "emptym",
})
