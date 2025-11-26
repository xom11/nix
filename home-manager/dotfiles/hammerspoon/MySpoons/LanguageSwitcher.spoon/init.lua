local obj = {}
obj.__index = obj

local vn = "Simple Telex"
local en = "Unicode Hex Input"

function obj:init()
	hs.loadSpoon("InputSourceSwitch")

	spoon.InputSourceSwitch:setApplications({
    ["kitty"] = en,
    ["iTerm2"] = en,
    ["Alacritty"] = en,
    ["Google Chrome"] = vn,
    ["Firefox"] = vn,
    ["Brave Browser"] = vn,
		["Google Gemini"] = vn,
    ["DeepSeek - Into the Unknown"] = vn,
    ["Telegram"] = vn,
    ["Messenger"] = vn,
    ["Zalo"] = vn,
    ["Visual Studio Code"] = en,
    ["System Settings"] = en,
    ["Notion"] = vn,
    ["Google Keep"] = vn,
    ["Youtube"] = vn,
    ["Finder"] = en,
	})

	spoon.InputSourceSwitch:start()
end
return obj
