hs = hs
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
local Install=spoon.SpoonInstall

tab = {"cmd", "alt", "ctrl", "shift"}
cap = { "ctrl", "alt", "cmd" }

Install:updateRepo('default')

-- -- Emojis selector. alt-e
-- Install:installSpoonFromRepo('Emojis')
-- local emojis = hs.loadSpoon('Emojis')
-- emojis.chooser:rows(15)
-- emojis:bindHotkeys({toggle={alt, 'e'}})

-- -- Hotkey cheatsheet.  alt-p
-- Install:installSpoonFromRepo('KSheet')
-- local sheet = hs.loadSpoon('KSheet')
-- sheet:bindHotkeys({toggle={alt, 'p'}})

-- Draw on screen (c)lear/(a)nnotate/(t)oggle
local drawonscreen = hs.loadSpoon("DrawOnScreen")
local hotkey = hs.hotkey.modal.new(tab, 'a')

function hotkey:entered()
  drawonscreen.start()
  drawonscreen.startAnnotating()
end

function hotkey:exited()
  drawonscreen.stopAnnotating()
  drawonscreen.hide()
end

hotkey:bind(tab, 'c', function() drawonscreen.clear() end)
hotkey:bind(tab, 'a', function() hotkey:exit() end)
hotkey:bind(tab, 't', function() drawonscreen.toggleAnnotating() end)

-- Reload config 
hs.hotkey.bind(tab, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")
if spoon.TrackpadReverse then
  spoon.TrackpadReverse:start()
end

-- Launch App shortcuts
hs.loadSpoon("LaunchApp")

local launchAppShortcuts = {
  {cap, "space", "kitty"},
  {cap, "A", "Launchpad"},
  {cap, "B", "Brave Browser"},
  {cap, "D", "Discord"},
  {tab, "D", "DeepSeek - Into the Unknown"},
  {cap, "F", "Finder"},
  {cap, "K", "Google Keep"},
  {cap, "G", "Google Gemini"},
  {cap, "M", "Messenger"},
  {cap, "N", "Notion"},
  {cap, "T", "Telegram"},
  {cap, "S", "System Settings"},
  {tab, "M", "Gmail"},
  {cap, "V", "Visual Studio Code"},
  {cap, "Y", "Youtube"},
  {cap, "Z", "Zalo"},
}

if spoon.LaunchApp and spoon.LaunchApp.launch then
  for _, shortcut in ipairs(launchAppShortcuts) do
    hs.hotkey.bind(shortcut[1], shortcut[2], function()
        spoon.LaunchApp.launch(shortcut[3])
    end)
  end
end

-- Power shortcuts
-- Lock screen
hs.hotkey.bind({"cmd", "alt"}, "L", function()
  hs.caffeinate.lockScreen()
end)
-- Shutdown
hs.hotkey.bind({"cmd", "alt", "shift"}, "S", function()
  local button, text = hs.dialog.blockAlert("Shutdown System", "Are you sure you want to shutdown the system?", "Shutdown", "Cancel")
  if button == "Cancel" then
    return
  end
  hs.caffeinate.shutdownSystem()
end)
-- Restart
hs.hotkey.bind({"cmd", "alt", "shift"}, "R", function()
  local button, text = hs.dialog.blockAlert("Restart System", "Are you sure you want to restart the system?", "Restart", "Cancel")
  if button == "Cancel" then
    return
  end
  hs.caffeinate.restartSystem()
end)