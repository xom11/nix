local obj = {}
obj.__index = obj

tab = { "cmd", "ctrl", "shift" }

function obj:init()
	-- PART: Reload config
	hs.hotkey.bind(tab, "R", function()
		hs.reload()
	end)
	-- PART: Toggle Console
	hs.hotkey.bind(tab, "H", function()
		hs.toggleConsole()
	end)
	-- PART: Analog clock
	spoon.SpoonInstall:andUse("AClock")
	hs.loadSpoon("AClock")
	hs.hotkey.bind(tab, "t", function()
		spoon.AClock:toggleShow()
	end)

	-- PART:Screenshot tool
	hs.hotkey.bind(tab, "s", function()
		hs.execute("screencapture -i -c")
	end)

	-- PART: Emoji picker
	spoon.SpoonInstall:andUse("Emojis")
	hs.loadSpoon("Emojis").chooser:rows(15)
	hs.loadSpoon("Emojis"):bindHotkeys({ toggle = { tab, "e" } })

	-- PART: Draw on screen
  -- (d)raw/(c)lear/(a)nnotate/(t)oggle
	local drawonscreen = hs.loadSpoon("DrawOnScreen")
	local hotkey = hs.hotkey.modal.new(tab, "d")

	function hotkey:entered()
		drawonscreen.start()
		drawonscreen.startAnnotating()
	end

	function hotkey:exited()
		drawonscreen.stopAnnotating()
		drawonscreen.hide()
	end

	hotkey:bind(tab, "c", function()
		drawonscreen.clear()
	end)
	hotkey:bind(tab, "d", function()
		hotkey:exit()
	end)
	hotkey:bind(tab, "t", function()
		drawonscreen.toggleAnnotating()
	end)
end
return obj
