# LaunchApp.spoon

Hyper key (cmd+ctrl+alt) app launcher with toggle behavior.

## Keybindings

| Key | Action |
|---|---|
| `hyper + key` | Launch or focus app. If already focused, switch to another app. |
| `hyper + shift + key` | Same, for the extended app list. |

The actual key → app table is not here — it is generated from
`configs/shortcuts/apps.toml`, the single source shared with Windows, GNOME
and sway. See `configs/shortcuts/README.md` for the current table.

## Two types of shortcuts

### Native apps (`launchNative`)
Opens macOS apps by name via bundle ID lookup.

Toggle logic:
- Not focused → focus it
- Already focused → `switchAway`: focus the next window from a **different** app; if none, hide the app

### Web apps (`launchWeb`)
Opens URLs in the browser using `--app=` flag (app/PWA mode, no tab bar).
Only works with Chromium-based browsers (Brave, Chrome, Vivaldi, Edge).

Toggle logic:
- Window not found → `open -na "<browser>" --args --app=<url>`
- Window found, not focused → focus it
- Window found, already focused → `switchAway`

Window detection uses AppleScript to query tab URLs in the browser,
since web app windows share the same bundle ID as the main browser.

## Bugs encountered & fixes

### Surfingkeys / Vimium shortcuts break after hide+focus
When hiding the browser and re-focusing it, keyboard extensions like Surfingkeys/Vimium
lose their shortcut context and stop working.

**Fix:** Use `switchAway` (switch to another app) instead of `app:hide()`.
`app:hide()` is only used as a last resort when no other window is available.

### PWA / web app bundle ID conflict
Web app windows opened with `--app=` share the same bundle ID as the main browser.
This means bundle-ID-based detection cannot distinguish them from regular browser windows.

**Fix:** Use AppleScript to query `URL of active tab of window` to match by URL pattern instead.

### hyper+b jumping between web app windows (not focusing real browser)
When focused on a web app window (e.g., Discord), pressing hyper+b triggered `switchAway`,
which found the next browser window — another web app — instead of a real browser window.

Root causes:
1. `switchAway` was not filtering same-bundle-ID windows, so it switched between
   web app windows of the same browser instead of going to a different app.
2. `findMainBrowserWindow` was declared after `launchNative` in the file —
   Lua resolved it as a global (nil) and silently failed, breaking hyper+b entirely.

**Fix:**
- `switchAway` now skips windows with the same bundle ID as the excluded window.
- `findMainBrowserWindow` is declared before `launchNative`.
- When toggling the browser (`appName == browser`) and focused on a web app window,
  `launchNative` calls `findMainBrowserWindow` to find a real (non-web-app) browser window
  and focuses it directly, instead of calling `switchAway`.
## Old version

- `git show 3a996ab:home-manager/dotfiles/hammerspoon/MySpoons/LaunchApp.spoon/init.lua` — v1: used installed PWA instead of launching with `--app=` URL
