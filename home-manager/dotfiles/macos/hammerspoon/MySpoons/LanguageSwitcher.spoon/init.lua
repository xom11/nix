local obj = {}
obj.__index = obj
-- NOTE:
-- Fcitx5 -> cn -> Gonhanh turn off -> en
-- ABC -> en -> Gonhanh turn on -> vn

-- local en = "Fcitx5"
local en = "Unicode Hex Input"
local vn = "ABC"

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
