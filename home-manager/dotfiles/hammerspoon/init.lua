hs = hs
spoon = spoon
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" ..  hs.configdir .. "/MySpoons/?.spoon/init.lua"

tab = {"cmd", "ctrl", "shift"}
cap = { "ctrl", "alt", "cmd" }

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:updateRepo('default')

spoon.SpoonInstall:andUse("RecursiveBinder")
spoon.SpoonInstall:andUse("AllBrightness")
-- Analog clock
spoon.SpoonInstall:andUse("AClock")
hs.hotkey.bind(tab, 't', function() spoon.AClock:toggleShow() end)
-- Screenshot tool
hs.hotkey.bind(tab, 's', function() hs.execute('screencapture -i -c') end)
-- Emoji picker
spoon.SpoonInstall:andUse("Emojis")
hs.loadSpoon('Emojis').chooser:rows(15)
hs.loadSpoon('Emojis'):bindHotkeys({toggle={tab, 'e'}})
-- ModalMgr
-- spoon.SpoonInstall:andUse("ModalMgr")

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
hs.hotkey.bind(tab, "R", function() hs.reload() end)
hs.alert.show("Config loaded")
-- Toggle Console
hs.hotkey.bind(tab, "H", function() hs.toggleConsole() end)

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")
spoon.TrackpadReverse:start()

hs.loadSpoon("LaunchApp")
-- hs.loadSpoon("LaunchTerminal")
hs.loadSpoon("PowerTool")
hs.loadSpoon("WindowManager")
hs.loadSpoon("Fn")


