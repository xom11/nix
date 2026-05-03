local obj = {}
obj.__index = obj

local tab = { "cmd", "ctrl", "shift" }

function obj:init()
	-- PART: Reload config
	hs.hotkey.bind(tab, "r", function()
		hs.reload()
	end)
  -- PART: Change language input source
  hs.hotkey.bind(tab, "e", function()
    hs.keycodes.setLayout("ABC")
  end)
  hs.hotkey.bind(tab, "v", function()
    hs.keycodes.setMethod("Fcitx5")
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
	-- PART: Battery status
	hs.hotkey.bind(tab, "p", function()
		hs.loadSpoon("ABattery")
		spoon.ABattery:toggleShow()
	end)
	-- PART: Screenshot tool — save local /tmp/ss.png + clipboard, push to macmini + rog
	-- using cmd + shift + 4 instead for paste in some apps that don't support image pasting, e.g. Claude-cli
	-- on remote, paste into Claude Code by typing: @/tmp/ss.png
	hs.hotkey.bind(tab, "s", function()
		local path = "/tmp/ss.png"
		hs.execute("/usr/sbin/screencapture -i " .. path)
		if hs.fs.attributes(path) then
			local img = hs.image.imageFromPath(path)
			if img then
				hs.pasteboard.writeObjects(img)
			end
			hs.execute("/usr/bin/scp " .. path .. " macmini:/tmp/ss.png &")
			hs.execute("/usr/bin/scp " .. path .. " rog:/tmp/ss.png &")
		end
	end)

	-- PART: Emoji picker
	-- spoon.SpoonInstall:andUse("Emojis")
	-- hs.loadSpoon("Emojis").chooser:rows(15)
	-- hs.loadSpoon("Emojis"):bindHotkeys({ toggle = { tab, "e" } })

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
