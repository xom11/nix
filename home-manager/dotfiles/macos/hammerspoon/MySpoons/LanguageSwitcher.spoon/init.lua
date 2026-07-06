local obj = {}
obj.__index = obj

-- local en = "Fcitx5"
local en = "Unicode Hex Input"
local vn = "ABC"
local zh = "Pinyin – Simplified"

local function switchLang(name)
	for _, v in ipairs(hs.keycodes.layouts()) do
		if v == name then
			hs.keycodes.setLayout(name)
			return
		end
	end
	hs.keycodes.setMethod(name)
end
hs.hotkey.bind({}, "f18", function() switchLang(en) end)
hs.hotkey.bind({}, "f19", function() switchLang(vn) end)
hs.hotkey.bind({}, "f17", function() switchLang(zh) end)


spoon.SpoonInstall:andUse("InputSourceSwitch")

function obj:init()
	hs.loadSpoon("InputSourceSwitch")

	spoon.InputSourceSwitch:setApplications({
		["Alacritty"] = en,
		["Brave Browser"] = en,
		["Finder"] = en,
		["Firefox"] = vn,
		["Google Chrome"] = vn,
		["System Settings"] = en,
		["Telegram"] = vn,
		["Visual Studio Code"] = en,
		["Vivaldi"] = en,
		["Zalo"] = vn,
		["iTerm2"] = en,
		["kitty"] = en,
		["Notion"] = vn,

    -- pwa apps
		["Claude"] = vn,
		["DeepSeek - Into the Unknown"] = vn,
		["Google Gemini"] = en,
		["Gemini"] = en,
		["Google Keep"] = vn,
		["Messenger"] = vn,
		["Youtube"] = vn,
	})

	spoon.InputSourceSwitch:start()
end
return obj
