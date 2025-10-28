# RUN-OR-RAISE

`Find the focused app name`
```bash
FOCUSED_APP_NAME=$(aerospace list-windows --focused --json | jq -r '.[0]."app-name"' 2>/dev/null)
```
Bug : APP_NAME = 'Visual Studio Code' and FOCUSED_APP_NAME = 'Code'

---

`Hide the focused app using AppleScript`
```bash
osascript -e 'tell application "System Events" to keystroke "h" using {command down}'
```
Bug : Very slow to hide using AppleScript

---

`Check if the app is frontmost using AppleScript`
```bash
IS_FRONTMOST=$(osascript -e "
    try
        tell application \"$APP_NAME\" to return its frontmost
    on error
        return false
    end try
" 2>/dev/null)
```
---

- Switch workspace
```bash
aerospace workspace-back-and-forth
```
- Hide app using Hammerspoon
```bash
hs -c 'local window = hs.window.focusedWindow(); if window then window:application():hide() end'
``` 
