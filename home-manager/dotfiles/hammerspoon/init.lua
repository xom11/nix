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
spoon.TrackpadReverse:start()

hs.loadSpoon("LaunchApp")
hs.loadSpoon("PowerTool")


spoon.SpoonInstall:andUse("FnMate")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)


spoon.SpoonInstall:andUse("RecursiveBinder")
