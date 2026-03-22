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
		["Vivaldi"] = vn,
		["DeepSeek - Into the Unknown"] = vn,
		["Finder"] = en,
		["Firefox"] = vn,
		["Google Chrome"] = vn,
		["Google Gemini"] = vn,
		["Google Keep"] = vn,
		["Messenger"] = vn,
		["Notion"] = vn,
		["System Settings"] = en,
		["Telegram"] = vn,
		["Visual Studio Code"] = en,
		["Youtube"] = vn,
		["Zalo"] = vn,
		["iTerm2"] = en,
		["kitty"] = en,
    ["Claude"] = vn,
	})

	spoon.InputSourceSwitch:start()
end
return obj
