hs = hs
spoon = spoon
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" .. hs.configdir .. "/MySpoons/?.spoon/init.lua"
package.path = package.path .. ";" .. hs.configdir .. "/LibSpoons/?.spoon/init.lua"

tab = { "cmd", "ctrl", "shift" }
cap = { "ctrl", "alt", "cmd" }

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:updateRepo("default")

spoon.SpoonInstall:andUse("RecursiveBinder")
spoon.SpoonInstall:andUse("AllBrightness")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")
spoon.TrackpadReverse:start()

hs.loadSpoon("LaunchApp")
-- hs.loadSpoon("LaunchTerminal")
hs.loadSpoon("PowerTool")
-- hs.loadSpoon("GoNhanh")
hs.loadSpoon("WindowManager")
hs.loadSpoon("Fn")
hs.loadSpoon("Tab")
hs.loadSpoon("LanguageSwitcher")
hs.loadSpoon("PolishPrompt")

hs.alert.show("Hammerspoon config loaded")


