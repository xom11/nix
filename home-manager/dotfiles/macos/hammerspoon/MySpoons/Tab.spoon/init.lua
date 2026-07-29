local obj = {}
obj.__index = obj

local tab = { "cmd", "ctrl", "shift" }

function obj:init()
	-- PART: Reload config
	hs.hotkey.bind(tab, "r", function()
		hs.reload()
	end)
	-- PART: Change language input source — Tab+Q=中文, Tab+W=Tiếng Việt, Tab+E=English
	--
	-- Dùng sourceID thay cho tên hiển thị. "Pinyin – Simplified" và "Unicode Hex Input" là
	-- chuỗi đã bản địa hoá, đổi theo ngôn ngữ hệ thống và theo phiên bản macOS. Bản cũ so
	-- tên trong hs.keycodes.layouts(), không khớp thì rơi xuống setMethod() — cả hai đều
	-- không báo gì khi thất bại, và giá trị trả về cũng bị bỏ. Đổi tên một cái là phím chết
	-- lặng lẽ.
	--
	-- sourceID cũng chính là thứ LanguageMemory ghi vào ~/.hammerspoon/LanguageMemory.json,
	-- nên sau thay đổi này hai chỗ dùng chung một định danh.
	--
	-- Ba ID dưới đọc từ chính máy này: đổi sang từng nguồn theo tên rồi hỏi currentSourceID().
	local SOURCES = {
		zh = "com.apple.inputmethod.SCIM.ITABC", -- Pinyin – Simplified
		vi = "com.apple.keylayout.ABC", -- ABC
		en = "com.apple.keylayout.UnicodeHexInput", -- Unicode Hex Input
	}

	-- currentSourceID(id) trả true khi đổi được, false khi nguồn chưa được bật trong
	-- System Settings (và giữ nguyên nguồn đang dùng, không làm hỏng trạng thái).
	local function switchLang(id)
		if not hs.keycodes.currentSourceID(id) then
			hs.alert.show("Không đổi được input source: " .. id, 2)
		end
	end

	hs.hotkey.bind(tab, "q", function() switchLang(SOURCES.zh) end)
	hs.hotkey.bind(tab, "w", function() switchLang(SOURCES.vi) end)
	hs.hotkey.bind(tab, "e", function() switchLang(SOURCES.en) end)
	-- PART: Toggle Console
	hs.hotkey.bind(tab, "H", function()
		hs.toggleConsole()
	end)
	-- PART: Analog clock
	-- AClock do Nix đặt vào ~/.hammerspoon/Spoons từ input hammerspoon-spoons; không cần
	-- SpoonInstall:andUse() để tải nữa (lời gọi đó vốn cũng thừa vì loadSpoon ngay dưới).
	hs.loadSpoon("AClock")
	hs.hotkey.bind(tab, "t", function()
		spoon.AClock:toggleShow()
	end)
	-- PART: Battery status
	hs.hotkey.bind(tab, "p", function()
		hs.loadSpoon("ABattery")
		spoon.ABattery:toggleShow()
	end)
	-- PART: Screenshot tool — chụp vùng chọn, copy vào clipboard, đẩy sang các máy khác.
	-- using cmd + shift + 4 instead for paste in some apps that don't support image pasting, e.g. Claude-cli
	-- on remote, paste into Claude Code by typing: @/tmp/ss.png
	--
	-- Không dùng hs.execute ở đây. hs.execute là io.popen + f:read("*a"), tức là chờ EOF trên
	-- pipe — kể cả khi lệnh có dấu `&`, vì tiến trình nền thừa kế đầu ghi của pipe nên EOF chỉ
	-- đến khi nó chết hẳn. ssh không đặt ConnectTimeout, nên một host không với tới được (airm3
	-- mang ra khỏi mạng nhà) treo cả Lua thread của Hammerspoon tới hết TCP timeout, ~75 s mỗi
	-- host, tuần tự. Trong lúc đó mọi hotkey — kể cả tab+r để reload thoát ra — đều chết.
	local ssHosts = { "macmini", "rog" }
	local ssLatest = "/tmp/ss.png"
	local ssKeep = 20

	-- Mỗi lần chụp là một đường dẫn mới nên /tmp phình dần; giữ lại ssKeep ảnh gần nhất.
	-- Tên chứa timestamp cố định độ dài nên sort chuỗi = sort thời gian.
	local function ssPrune()
		local files = {}
		local ok = pcall(function()
			for f in hs.fs.dir("/tmp") do
				if f:match("^ss%-%d+%-%d+%.png$") then
					files[#files + 1] = f
				end
			end
		end)
		if not ok then
			return
		end
		table.sort(files)
		for i = 1, #files - ssKeep do
			os.remove("/tmp/" .. files[i])
		end
	end

	local function ssPush(path)
		-- Bỏ qua chính máy đang chạy: bản cũ scp /tmp/ss.png lên macmini kể cả khi đang ngồi
		-- ở macmini, tức là copy file lên chính nó.
		local me = (hs.host.localizedName() or ""):lower()
		for _, host in ipairs(ssHosts) do
			if host ~= me then
				hs.task.new("/usr/bin/scp", function(exitCode, _stdout, stderr)
					if exitCode ~= 0 then
						local msg = (stderr or ""):gsub("%s+$", "")
						if msg == "" then
							msg = "exit code " .. tostring(exitCode)
						end
						hs.alert.show("scp " .. host .. ": " .. msg, 3)
					end
					-- BatchMode: không bao giờ dừng lại hỏi mật khẩu/passphrase.
					-- ConnectTimeout: bỏ cuộc sau 5 s thay vì chờ hết TCP timeout.
				end, { "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", path, host .. ":" .. ssLatest }):start()
			end
		end
	end

	hs.hotkey.bind(tab, "s", function()
		-- Đường dẫn duy nhất mỗi lần chụp. Bản cũ ghi đè một tên cố định, nên khi user bấm Esc
		-- huỷ vùng chọn thì screencapture không ghi gì, mà hs.fs.attributes() vẫn thấy ảnh của
		-- lần TRƯỚC còn nằm đó — rồi đem ảnh cũ đó vào clipboard và scp sang cả hai máy.
		local path = "/tmp/ss-" .. os.date("%Y%m%d-%H%M%S") .. ".png"

		hs.task.new("/usr/sbin/screencapture", function()
			-- Không xét exit code: screencapture vẫn thoát 0 khi user huỷ. Bằng chứng duy nhất
			-- đáng tin là file có xuất hiện ở đường dẫn mới hay không.
			if not hs.fs.attributes(path) then
				return
			end

			local img = hs.image.imageFromPath(path)
			if img then
				hs.pasteboard.writeObjects(img)
			end

			-- Giữ /tmp/ss.png trỏ về ảnh mới nhất để `@/tmp/ss.png` vẫn dùng được như trước.
			os.remove(ssLatest)
			hs.fs.link(path, ssLatest, true)

			ssPush(path)
			ssPrune()
		end, { "-i", path }):start()
	end)

	-- PART: Caffeinate toggle — keep main display awake, show corner indicator
	local caffeineOn = false
	local size, inset = 30, 6
	local sf = hs.screen.primaryScreen():frame()
	local caffeineCanvas = hs.canvas.new({ x = sf.x + sf.w - size - inset, y = sf.y + inset, w = size, h = size })
	caffeineCanvas:level("overlay"):behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
	caffeineCanvas:appendElements(
		{
			type = "rectangle",
			action = "fill",
			roundedRectRadii = { xRadius = 9, yRadius = 9 },
			fillColor = { red = 1, green = 0.25, blue = 0.1, alpha = 0.95 },
		},
		{
			type = "text",
			text = "☕",
			textSize = 20,
			textAlignment = "center",
			frame = { x = 0, y = 4, w = size, h = size },
		}
	)

	local function setCaffeine(on)
		caffeineOn = on
		hs.caffeinate.set("displayIdle", on)
		if on then
			caffeineCanvas:show()
		else
			caffeineCanvas:hide()
		end
	end

	hs.hotkey.bind(tab, "c", function()
		setCaffeine(not caffeineOn)
	end)

	-- PART: Emoji picker
	-- spoon.SpoonInstall:andUse("Emojis")
	-- hs.loadSpoon("Emojis").chooser:rows(15)
	-- hs.loadSpoon("Emojis"):bindHotkeys({ toggle = { tab, "e" } })

	-- PART: Draw on screen
	-- (d)raw/(c)lear/(a)nnotate/(t)oggle
	local drawonscreen = hs.loadSpoon("DrawOnScreen")
	local hotkey = hs.hotkey.modal.new(tab, "d")

	function hotkey:entered()
		drawonscreen.start()
		drawonscreen.startAnnotating()
	end

	function hotkey:exited()
		drawonscreen.stopAnnotating()
		drawonscreen.hide()
	end

	hotkey:bind(tab, "c", function()
		drawonscreen.clear()
	end)
	hotkey:bind(tab, "d", function()
		hotkey:exit()
	end)
	hotkey:bind(tab, "t", function()
		drawonscreen.toggleAnnotating()
	end)
end
return obj
