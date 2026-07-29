--- === Tab ===
---
--- Lớp phím "tab". kanata biến Tab-giữ thành cmd+ctrl+shift
--- (configs/kanata/kanata_macos.kbd, alias tab_alias), nên mọi phím dưới đây trên thực tế là
--- Tab + <phím>.
---
--- File này chỉ còn là bảng nối phím. Trước đây nó gom 8 tính năng không liên quan gì nhau
--- vào một chỗ; những phần có sức nặng đã tách sang LibSpoons và tự khai báo bindHotkeys của
--- chúng, nên đổi phím chỉ cần sửa đúng ở đây:
---
---   LangSwitch.spoon  q / w / e
---   Screenshot.spoon  s
---   Caffeine.spoon    c
---   Annotate.spoon    d  (modal)

local obj = {}
obj.__index = obj

local tab = { "cmd", "ctrl", "shift" }

function obj:init()
	-- Nạp lại config
	hs.hotkey.bind(tab, "r", function()
		hs.reload()
	end)

	-- Bật/tắt Console
	hs.hotkey.bind(tab, "h", function()
		hs.toggleConsole()
	end)

	-- Đồng hồ kim
	hs.loadSpoon("AClock")
	hs.hotkey.bind(tab, "t", function()
		spoon.AClock:toggleShow()
	end)

	-- Trạng thái pin
	hs.loadSpoon("ABattery")
	hs.hotkey.bind(tab, "p", function()
		spoon.ABattery:toggleShow()
	end)

	-- Đổi input source — q=中文, w=Tiếng Việt, e=English
	hs.loadSpoon("LangSwitch"):bindHotkeys({
		zh = { tab, "q" },
		vi = { tab, "w" },
		en = { tab, "e" },
	})

	-- Chụp màn hình vùng chọn, copy vào clipboard, đẩy sang máy khác
	hs.loadSpoon("Screenshot"):bindHotkeys({ capture = { tab, "s" } })

	-- Giữ màn hình không tự tắt
	hs.loadSpoon("Caffeine"):bindHotkeys({ toggle = { tab, "c" } })

	-- Vẽ lên màn hình. tab+d vào modal; trong modal: c=xoá nét, t=bật/tắt vẽ,
	-- d hoặc Escape=thoát. Hai phím c và t ở đây CỐ Ý trùng với Caffeine và AClock:
	-- modal che chúng trong lúc đang vẽ rồi trả lại khi thoát.
	hs.loadSpoon("Annotate"):bindHotkeys({
		enter = { tab, "d" },
		clear = { tab, "c" },
		toggle = { tab, "t" },
	})

	-- Emoji picker (chưa bật)
	-- hs.loadSpoon("Emojis").chooser:rows(15)
	-- hs.loadSpoon("Emojis"):bindHotkeys({ toggle = { tab, "e" } })
end

return obj
