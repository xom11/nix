--- === PowerManager ===
---
--- Khoá màn hình / ngủ / tắt máy / khởi động lại / đăng xuất.
---
---   cmd+alt+L        khoá màn hình
---   cmd+alt+S        ngủ
---   cmd+alt+shift+S  tắt máy      (hỏi xác nhận)
---   cmd+alt+shift+R  khởi động lại (hỏi xác nhận)
---   cmd+alt+shift+L  đăng xuất

local obj = {}
obj.__index = obj

local DIALOG_W, DIALOG_H = 400, 200

-- Hỏi xác nhận mà KHÔNG chặn Lua.
--
-- Bản cũ dùng hs.dialog.blockAlert. Tài liệu đi kèm bản cài ghi thẳng: "will halt Lua code
-- processing until the alert is closed" — nghĩa là suốt lúc hộp thoại còn mở, mọi hotkey (kể
-- cả tab+r để reload thoát ra), eventtap của Fn và TrackpadReverse, appWatcher của
-- LanguageMemory đều ngừng chạy. Hộp thoại "bạn có chắc muốn tắt máy" thì thường được trả lời
-- nhanh, nhưng nếu nó mở ra sau lưng một cửa sổ full-screen và không ai thấy, cả Hammerspoon
-- đứng hình cho tới khi tìm ra nó.
--
-- hs.dialog.alert làm đúng việc đó qua callback, không chặn.
local function confirm(title, text, okLabel, action)
	-- Tính vị trí lúc gọi chứ không lưu sẵn: màn hình chính có thể đã đổi kể từ lúc load.
	local f = hs.screen.primaryScreen():frame()
	hs.dialog.alert(
		f.x + (f.w - DIALOG_W) / 2,
		f.y + (f.h - DIALOG_H) / 2,
		function(button)
			if button == okLabel then
				action()
			end
		end,
		title,
		text,
		okLabel,
		"Cancel",
		"critical"
	)
end

function obj:init()
	-- Khoá màn hình
	hs.hotkey.bind({ "cmd", "alt" }, "l", function()
		hs.caffeinate.lockScreen()
	end)

	-- Ngủ
	hs.hotkey.bind({ "cmd", "alt" }, "s", function()
		hs.caffeinate.systemSleep()
	end)

	-- Tắt máy
	hs.hotkey.bind({ "cmd", "alt", "shift" }, "s", function()
		confirm("Shutdown System", "Are you sure you want to shutdown the system?", "Shutdown", function()
			hs.caffeinate.shutdownSystem()
		end)
	end)

	-- Khởi động lại
	hs.hotkey.bind({ "cmd", "alt", "shift" }, "r", function()
		confirm("Restart System", "Are you sure you want to restart the system?", "Restart", function()
			hs.caffeinate.restartSystem()
		end)
	end)

	-- Đăng xuất.
	--
	-- Cố ý KHÔNG thêm hộp xác nhận ở đây, dù nó nằm ngay cạnh cmd+alt+L (khoá màn hình) và chỉ
	-- hơn đúng một phím shift: macOS vẫn cho từng app cơ hội chặn việc đăng xuất, nên lỡ tay
	-- không đồng nghĩa mất dữ liệu. Thêm xác nhận là thêm ma sát cho một thao tác chủ đích.
	hs.hotkey.bind({ "cmd", "alt", "shift" }, "l", function()
		hs.caffeinate.logOut()
	end)
end

return obj
