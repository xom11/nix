local obj = {}
obj.__index = obj
-- INFO: macos telex very bad, Fcitx5 much better

local vn = "Fcitx5"
local en = "ABC"

spoon.SpoonInstall:andUse("InputSourceSwitch")

function obj:init()
	hs.loadSpoon("InputSourceSwitch")

	spoon.InputSourceSwitch:setApplications({
		["Alacritty"] = en,
		["Brave Browser"] = vn,
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
		["kitty"] = en, -- BUG conflict with switch language in nvim
    ["Claude"] = vn,
	})

	spoon.InputSourceSwitch:start()
end
return obj
