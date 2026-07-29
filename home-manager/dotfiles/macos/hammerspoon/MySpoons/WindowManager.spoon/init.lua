local obj = {}
obj.__index = obj

local hyper = { "cmd", "alt", "ctrl" }

-- Khung gốc của cửa sổ trước khi phóng to, tra theo window id.
--
-- Lưu kèm UUID màn hình vì frame là toạ độ TUYỆT ĐỐI: phóng to trên màn ngoài, rút màn ra,
-- rồi bấm khôi phục thì bản cũ ném cửa sổ về toạ độ của một màn hình không còn tồn tại —
-- cửa sổ biến mất khỏi vùng nhìn thấy được.
local originalFrames = {}

-- macOS tái sử dụng window id sau khi cửa sổ đóng, nên bảng này vừa phình mãi không ai dọn,
-- vừa có thể trả khung của một cửa sổ đã chết cho cửa sổ mới trùng id.
--
-- Dọn lười ngay trước khi dùng, thay vì subscribe hs.window.filter.windowDestroyed: callback
-- của filter nhận userdata của cửa sổ ĐÃ huỷ, gọi w:id() trên đó là ném lỗi mỗi lần đóng cửa
-- sổ. hs.window.get(id) trả nil cho id đã chết nên cách này vừa đúng vừa rẻ.
local function prune()
	for id in pairs(originalFrames) do
		if not hs.window.get(id) then
			originalFrames[id] = nil
		end
	end
end

-- Gom phần lặp lại của cả ba phím: lấy cửa sổ đang focus và khung khả dụng của màn hình
-- chứa nó. Không có cửa sổ (đang ở Desktop, hoặc app không có cửa sổ nào) thì bỏ qua.
local function withFocused(fn)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local screen = win:screen()
	if not screen then
		return
	end
	fn(win, screen:frame())
end

function obj:init()
	-- Tắt animation khi đặt lại khung. Để trong init() chứ không phải ở top-level module:
	-- top-level chạy ngay lúc require, tức là đổi một biến toàn cục của hs.window chỉ vì file
	-- này được nạp, kể cả khi spoon chưa được init.
	hs.window.animationDuration = 0

	-- Nửa bên trái
	hs.hotkey.bind(hyper, ",", function()
		withFocused(function(win, max)
			win:setFrame({ x = max.x, y = max.y, w = max.w / 2, h = max.h })
		end)
	end)

	-- Nửa bên phải
	hs.hotkey.bind(hyper, ".", function()
		withFocused(function(win, max)
			win:setFrame({ x = max.x + (max.w / 2), y = max.y, w = max.w / 2, h = max.h })
		end)
	end)

	-- Toggle Maximize
	hs.hotkey.bind(hyper, "/", function()
		withFocused(function(win, max)
			prune()

			-- Một số cửa sổ (sheet, dialog, vài PWA) không có id; bản cũ gán
			-- originalFrames[nil] = ... và ném "table index is nil".
			local id = win:id()
			if not id then
				win:setFrame(max)
				return
			end

			local uuid = win:screen():getUUID()
			local saved = originalFrames[id]

			if saved and saved.screen == uuid then
				win:setFrame(saved.frame)
				originalFrames[id] = nil
			else
				-- Chưa lưu, hoặc đã lưu nhưng cho màn hình khác (khung cũ vô nghĩa ở đây):
				-- coi như lần phóng to mới.
				originalFrames[id] = { frame = win:frame(), screen = uuid }
				win:setFrame(max)
			end
		end)
	end)
end

function obj:stop()
	originalFrames = {}
	return self
end

return obj
