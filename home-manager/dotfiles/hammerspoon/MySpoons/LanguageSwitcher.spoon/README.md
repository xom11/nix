# LanguageSwitcher.spoon

Automatically switches input source when changing focus between apps or browser windows.

## How it works

### App-level switching (`InputSourceSwitch`)
Uses the `InputSourceSwitch` spoon to switch input source whenever the focused app changes.
Configured per app name.

### Browser window-level switching (`hs.window.filter`)
`InputSourceSwitch` only works per app name — it cannot distinguish between different windows
of the same app. Since all `--app=` web app windows share the same bundle ID as the browser,
they all appear as the same app.

To handle this, a `hs.window.filter` watches focus changes inside the browser,
queries the active tab URL via AppleScript, and switches input source based on URL pattern.

## Input sources

| Variable | Layout | Used for |
|---|---|---|
| `en` | Unicode Hex Input | terminals, code editors, browser (default) |
| `vn` | ABC + GoNhanh | chat, social, productivity apps |

GoNhanh is a separate tool that intercepts keystrokes on top of the ABC layout to produce Vietnamese characters.

## Bugs encountered & fixes

### Web app windows not switching input source
After moving from installed PWAs to `--app=` URLs (in LaunchApp.spoon),
apps like Claude, Gemini, Telegram etc. lost their per-app input source rules
because they no longer have their own app name — they all run under the browser.

**Fix:** Add a `hs.window.filter` that checks the URL of the focused browser window
via AppleScript and switches input source based on URL pattern matching.

### Race condition: InputSourceSwitch overrides windowFilter
Both `InputSourceSwitch` (app-level) and `browserFilter` (window-level) fire on the same
focus event. If `InputSourceSwitch` fires last, it overrides the URL-based source set by
`browserFilter`, resulting in all Vivaldi windows always using `browserDefault`.

**Fix:** Remove Vivaldi from `InputSourceSwitch` entirely. Let `browserFilter` handle
all Vivaldi windows (both real browser and web apps), eliminating the conflict.

## Old version

- `git show d7e8893:home-manager/dotfiles/hammerspoon/MySpoons/LanguageSwitcher.spoon/init.lua` — v1: used installed PWA app names in `InputSourceSwitch`, no per-window URL switching
