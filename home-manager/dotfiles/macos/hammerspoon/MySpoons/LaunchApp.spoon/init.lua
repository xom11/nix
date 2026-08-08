--- LaunchApp.spoon — beckon-backed focus-or-launch.
---
--- The previous version (`init.lua.backup`) implemented the
--- focus / hide / toggle-back logic in pure Lua via osascript +
--- hs.application.launchOrFocusByBundleID + hs.window.orderedWindows.
---
--- This version delegates the whole algorithm to `beckon` (Rust CLI). The
--- spoon's only job now is binding hotkeys and calling out to beckon with
--- the user-friendly Name. beckon resolves the Name against
--- LaunchServices, and runs the full focus / launch / cycle / toggle / hide
--- algorithm — including step 5a (cycle within an app's windows) which the
--- old Lua version skipped.
---
--- Bang phim (danh sach nao bam phim nao) khong con nam trong file nay --
--- xem configs/shortcuts/apps.toml.
---
--- See https://github.com/xom11/beckon

local obj = {}
obj.__index = obj

local hyper = { "cmd", "ctrl", "alt" }

-- Bang phim song o configs/shortcuts/apps.toml, dung chung voi Windows, GNOME
-- va sway. Spoon nay chi con viec bind phim va goi beckon.
--
-- KHONG dung duong dan tuong doi: ~/.hammerspoon/MySpoons di qua hai lop
-- symlink (~/.hammerspoon/MySpoons -> store -> repo), nen cho file nay nam
-- khong noi len cho repo nam. repoPath luon la $HOME/.nix (lib/mkConfigs.nix).
-- NIX_SHORTCUTS_DIR de test tro sang cho khac.
local shortcutsDir = os.getenv("NIX_SHORTCUTS_DIR")
	or ((os.getenv("HOME") or "") .. "/.nix/configs/shortcuts")

local hyperShift = { "cmd", "ctrl", "alt", "shift" }

--- @return table|nil bindings, string|nil err
local function loadBindings()
	local ok, parser = pcall(dofile, shortcutsDir .. "/parse.lua")
	if not ok then
		return nil, "khong nap duoc parse.lua: " .. tostring(parser)
	end

	local f = io.open(shortcutsDir .. "/apps.toml", "r")
	if not f then
		return nil, "khong mo duoc apps.toml o " .. shortcutsDir
	end
	local text = f:read("*a")
	f:close()

	local layers, err = parser.parse(text)
	if not layers then
		return nil, "apps.toml: " .. err
	end

	return {
		app = parser.bindings(layers, "app", "macos"),
		shift = parser.bindings(layers, "shift", "macos"),
	}
end

-- Path to the beckon binary. We DON'T use `hs.execute(cmd, true)` because
-- the second arg sources the user's login shell (~/.zshrc) before each
-- invocation — on a typical machine that's 200–1000 ms, on this user's
-- setup it exceeds 10 s. Calling beckon directly from a known absolute
-- path bypasses shell startup entirely.
--
-- /etc/profiles/per-user/<user>/bin is where home-manager's useUserPackages
-- places the symlinks for `home.packages`, so this resolves the same binary
-- that `which beckon` would resolve from a normal terminal session.
-- hs.task đòi đường dẫn tuyệt đối, không nhận tên lệnh trần, nên phải tự dò. Dò một lần lúc
-- init rồi nhớ lại, thay vì dựng lại chuỗi ở mỗi lần bấm phím.
--
-- Ba vị trí phủ cả ba kiểu cài Nix: profile người dùng (home-manager standalone),
-- useUserPackages của nix-darwin/NixOS, và system profile. Bản cũ chỉ biết đúng vị trí thứ hai.
local beckonCandidates = {
	(os.getenv("HOME") or "") .. "/.nix-profile/bin/beckon",
	"/etc/profiles/per-user/" .. (os.getenv("USER") or "") .. "/bin/beckon",
	"/run/current-system/sw/bin/beckon",
}

local beckonBin = nil

local function resolveBeckon()
	for _, p in ipairs(beckonCandidates) do
		if hs.fs.attributes(p, "mode") == "file" then
			return p
		end
	end
	return nil
end

-- Fire and forget via hs.task — non-blocking. beckon exits in ~20 ms but
-- macOS focus changes are async anyway, so there's nothing useful to wait
-- for. We attach a callback that surfaces a desktop alert if beckon exits
-- with non-zero status (typical: app id didn't resolve).
local function beckon(name)
	if not beckonBin then
		hs.alert.show("beckon: không tìm thấy binary ở " .. #beckonCandidates .. " vị trí đã dò", 4)
		return
	end

	local task = hs.task.new(beckonBin, function(exitCode, _stdout, stderr)
		if exitCode ~= 0 then
			local msg = (stderr or ""):gsub("%s+$", "")
			if msg == "" then
				msg = "exit code " .. tostring(exitCode)
			end
			hs.alert.show("beckon " .. name .. ": " .. msg, 3)
		end
	end, { name })

	-- start() trả về false khi không exec được (binary biến mất giữa chừng, mất bit thực thi).
	-- Trong ca đó callback KHÔNG BAO GIỜ chạy, nên nhánh alert ở trên không cứu được — bấm
	-- phím sẽ không ra gì và cũng không báo gì. Đó chính là hành vi của bản cũ.
	if not task or not task:start() then
		hs.alert.show("beckon không chạy được: " .. name, 3)
	end
end

function obj:init()
	beckonBin = resolveBeckon()
	if not beckonBin then
		hs.alert.show("LaunchApp: khong tim thay beckon -- phim hyper se khong co tac dung", 5)
	end

	local b, err = loadBindings()
	if not b then
		-- KHONG fallback bang cung. Fallback im lang nghia la sua apps.toml,
		-- reload, thay phim cu van chay, va tuong da ap dung.
		hs.alert.show("LaunchApp: " .. err, 8)
		return
	end

	-- hs.hotkey.bind co the loi neu s.key khong phai ten phim Hammerspoon nhan
	-- duoc (vd "comma" -- keysym xkb hop le va token dconf hop le nhung
	-- Hammerspoon doi ","). Khong gi trong CI kiem dieu do (xem
	-- configs/shortcuts/apps.toml header). ~/.hammerspoon/init.lua ghi ro: loi
	-- KHONG bat trong :init() cua mot spoon chan MOI hs.loadSpoon con lai sau
	-- no trong danh sach -- boc pcall rieng tung binding de mot key hong chi
	-- mat mot phim, khong lam sap ca cac spoon phia sau LaunchApp.
	for _, s in ipairs(b.app) do
		local ok, err = pcall(hs.hotkey.bind, hyper, s.key, function()
			beckon(s.id)
		end)
		if not ok then
			hs.alert.show("LaunchApp: bind phim " .. tostring(s.key) .. " (app) loi: " .. tostring(err), 5)
		end
	end

	for _, s in ipairs(b.shift) do
		local ok, err = pcall(hs.hotkey.bind, hyperShift, s.key, function()
			beckon(s.id)
		end)
		if not ok then
			hs.alert.show("LaunchApp: bind phim " .. tostring(s.key) .. " (shift) loi: " .. tostring(err), 5)
		end
	end
end

return obj
