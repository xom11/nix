-- Enable Hammerspoon CLI (`hs -c "..."`)
--
-- cliInstall() only symlinks when cliStatus() is exactly `false`. A half-install returns the
-- string "broken", which is truthy, so the install branch never runs and a bare cliInstall()
-- prints "incomplete installation" on every load forever. Uninstall-then-install is the way out.
if hs.ipc.cliStatus(nil, true) ~= true then
    hs.ipc.cliUninstall()
    hs.ipc.cliInstall()
end

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" .. hs.configdir .. "/MySpoons/?.spoon/init.lua"
package.path = package.path .. ";" .. hs.configdir .. "/LibSpoons/?.spoon/init.lua"

-- The real modifiers come from kanata (configs/kanata/kanata_macos.kbd): holding Tab is
-- cmd+ctrl+shift, holding Caps is cmd+ctrl+alt. Nothing here defines them.

-- Third-party spoons come from Nix, pinned in flake.lock (see default.nix). This used to be
-- SpoonInstall, which fetched a 1.2 MB index synchronously on every load and every reload --
-- and since Spoons/ is gitignored, a fresh clone with no network got nil back from
-- hs.loadSpoon and silently lost that spoon's hotkeys.
hs.loadSpoon("RecursiveBinder")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")

-- Focus-or-launch is beckon serve (launchd com.xom11.beckon-serve), reading
-- configs/shortcuts/launch-app.toml -- edits apply immediately, no reload.
-- hs.loadSpoon("LaunchTerminal")
hs.loadSpoon("PowerManager")
hs.loadSpoon("WindowManager")
hs.loadSpoon("Fn")
hs.loadSpoon("Tab")

-- Input mode is `tongue`, driven by LangSwitch.spoon (hotkeys, loaded via Tab.spoon) and
-- LanguageMemory.spoon (per-app memory). Two older spoons were dropped: GoNhanh.spoon did
-- tongue's job and took LanguageMemory's single global inputSourceChanged slot, and
-- LanguageSwitcher.spoon had been broken for a while and duplicated LanguageMemory.
hs.loadSpoon("LanguageMemory")

-- Mute on lock, restore on unlock. No bindHotkeys -- it only listens to a watcher.
hs.loadSpoon("LockMute")

hs.alert.show("Hammerspoon config loaded")


