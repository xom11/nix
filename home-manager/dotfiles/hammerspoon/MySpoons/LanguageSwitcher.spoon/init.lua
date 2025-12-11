local obj = {}
obj.__index = obj

local vn = "Fcitx5"
local en = "ABC"

function obj:init()
	hs.loadSpoon("InputSourceSwitch")

	spoon.InputSourceSwitch:setApplications({
		["Google Gemini"] = vn,
    ["Alacritty"] = en,
    ["Brave Browser"] = vn,
    ["DeepSeek - Into the Unknown"] = vn,
    ["Finder"] = en,
    ["Firefox"] = vn,
    ["Google Chrome"] = vn,
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
	})

	spoon.InputSourceSwitch:start()
end
return obj
