# Caffeinate Toggle (`tab+c`) — Design

**Date:** 2026-06-19
**File:** `home-manager/dotfiles/macos/hammerspoon/MySpoons/Tab.spoon/init.lua`

## Goal

Bind `tab+c` to toggle macOS caffeinate (keep the main display awake) with a
persistent corner indicator so the state is never forgotten.

## Behavior

- `tab+c` toggles `hs.caffeinate.set("displayIdle", on)` — prevents the main
  display from sleeping. System idle/lid-close sleep is unaffected.
- ON → display stays awake + indicator shown. Press again → caffeinate off +
  indicator hidden.
- State is held in a local `caffeineOn` boolean.
- On config reload (`tab+r`) or Hammerspoon restart everything resets to **off**.
  This is intentional and safe.

## Indicator

- Drawn with `hs.canvas` on the **primary screen only**, **top-right** corner.
- Small, discreet: a ☕ glyph on a rounded translucent amber background
  (~28px), a few px inset from the top-right edge.
- `canvas:level("overlay")` and a `behavior` so it floats above apps and shows
  on all Spaces.
- Created once during `init()`, hidden by default. Toggled via `show()`/`hide()`.
- Display-only — not clickable.

## Code structure

Add a `-- PART: Caffeinate toggle` block to `Tab.spoon/init.lua`:

1. Build the indicator canvas once in `init()` (hidden initially).
2. `setCaffeine(on)` — calls `hs.caffeinate.set`, shows/hides canvas, updates
   `caffeineOn`.
3. `hs.hotkey.bind(tab, "c", ...)` flips the state.

Keep the existing `-- PART:` style; do not touch unrelated blocks.

## Out of scope (YAGNI)

Multi-monitor display, click-to-toggle, auto-off timer, elapsed-time display.
