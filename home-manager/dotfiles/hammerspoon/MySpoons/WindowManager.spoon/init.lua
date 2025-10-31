local obj = {}
obj.__index = obj

-- Bật/Tắt Animation
hs.window.animationDuration = 0

-- Lưu trữ khung hình (frame) gốc của cửa sổ trước khi phóng to (dành cho phím Up)
local originalFrames = {}

-- Hàm khởi tạo và kích hoạt Spoon
function obj:init()
	-- Gán phím tắt cho Nửa bên trái 
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, ",", function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end
		local f = win:frame()
		local screen = win:screen()
		local max = screen:frame()

		f.x = max.x
		f.y = max.y
		f.w = max.w / 2
		f.h = max.h
		win:setFrame(f)
	end)

	-- Gán phím tắt cho Nửa bên phải
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, ".", function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end
		local f = win:frame()
		local screen = win:screen()
		local max = screen:frame()

		f.x = max.x + (max.w / 2)
		f.y = max.y
		f.w = max.w / 2
		f.h = max.h
		win:setFrame(f)
	end)

	-- Gán phím tắt cho Toggle Maximize (Up)
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "/", function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end

		local windowID = win:id()
		local screen = win:screen()
		local maxFrame = screen:frame()

		if originalFrames[windowID] then
			-- Khôi phục lại khung hình gốc
			win:setFrame(originalFrames[windowID])
			originalFrames[windowID] = nil
		else
			-- Lưu khung hình hiện tại và Phóng to
			originalFrames[windowID] = win:frame()
			win:setFrame(maxFrame)
		end
	end)

end

-- Hàm hủy bỏ (Không cần thiết lắm cho ví dụ này, nhưng là một phần tốt của Spoon)
function obj:stop()
	-- Hàm này có thể được dùng để hủy các hotkey nếu cần
end

return obj
