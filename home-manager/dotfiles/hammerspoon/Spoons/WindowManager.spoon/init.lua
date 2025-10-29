local obj = {}
obj.__index = obj

-- Bật/Tắt Animation
hs.window.animationDuration = 0

-- Lưu trữ khung hình (frame) gốc của cửa sổ trước khi phóng to (dành cho phím Up)
local originalFrames = {}

-- Hàm khởi tạo và kích hoạt Spoon
function obj:init()
	-- Gán phím tắt cho Nửa bên trái (Left)
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function()
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

	-- Gán phím tắt cho Nửa bên phải (Right)
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function()
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
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", function()
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

	-- Gán phím tắt cho Trung tâm (50%x50%) (Down)
	hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end

		local screen = win:screen()
		local maxFrame = screen:frame()

		local newW = maxFrame.w / 2
		local newH = maxFrame.h / 2
		local newX = maxFrame.x + (maxFrame.w / 4)
		local newY = maxFrame.y + (maxFrame.h / 4)

		local newFrame = { x = newX, y = newY, w = newW, h = newH }
		win:setFrame(newFrame)
	end)
end

-- Hàm hủy bỏ (Không cần thiết lắm cho ví dụ này, nhưng là một phần tốt của Spoon)
function obj:stop()
	-- Hàm này có thể được dùng để hủy các hotkey nếu cần
end

return obj

