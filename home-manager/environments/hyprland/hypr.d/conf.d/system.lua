-- Dich tay tu sway.d/conf.d/system.conf.

local vars = require("vars")
local mod, alt = vars.mod, vars.alt
local modAlt = mod .. " + " .. alt

-- =============================================================================
-- `hyprctl dispatch` DA DOI CU PHAP KHI CONFIG LA LUA — day la cai bay lon nhat
-- cua dot chuyen doi nay, vi no o TRONG CHUOI SHELL nen khong bo kiem tra config
-- nao nhin thay.
--
-- HyprCtl.cpp, `dispatchRequest`: neu config manager la Lua thi ca phan con lai
-- cua dong duoc boc thanh `return hl.dispatch(<phan do>)` roi eval bang Lua.
-- Nghia la:
--     hyprctl dispatch exit         -> return hl.dispatch(exit)      -> `exit` la nil
--     hyprctl dispatch dpms off     -> return hl.dispatch(dpms off)  -> loi cu phap
-- Ca hai deu KHONG lam gi ca, chi in ra mot dong loi ma khong ai doc — lenh nam
-- trong tham so cua swayidle va trong duong ong rofi.
--
-- Ban dung phai la mot BIEU THUC LUA:
--     hyprctl dispatch "hl.dsp.exit()"
--     hyprctl dispatch "hl.dsp.dpms{action=[[off]]}"
--
-- Ba lop nhay long nhau, va thu tu chon la BAT BUOC chu khong phai gu:
--   1. swayidle nhan lenh trong nhay DON  '...'
--   2. shell can nhay KEP  "..."  quanh bieu thuc Lua, vi `(`/`{`/`}` la ky tu
--      dac biet cua shell
--   3. chuoi Lua ben trong phai KHONG dung dau nhay nao — `[[off]]` la chuoi
--      long-bracket cua Lua, dung dung o day
-- Doi `[[off]]` thanh `'off'` la nhay don do dong som tham so cua swayidle;
-- doi thanh `"off"` la dong som nhay kep cua shell. Ca hai deu im lang.
--
-- Ban than hai chuoi duoi day thi khai bang nhay DON cua Lua, nen `"` va `[[`
-- ben trong chi la ky tu thuong.
-- =============================================================================
local dpmsOff = 'hyprctl dispatch "hl.dsp.dpms{action=[[off]]}"'
local dpmsOn = 'hyprctl dispatch "hl.dsp.dpms{action=[[on]]}"'

-- =============================================================================
-- Background Services + Idle & Lock
--
-- `exec-once` cua hyprlang -> `hl.on("hyprland.start", ...)`. Su kien do chi
-- ban MOT lan luc compositor len; `hyprctl reload` chay lai ca file nay va dang
-- ky lai callback, nhung khong ban lai su kien — dung ngu nghia exec-once. Do
-- cung la ly do KHONG co doi ung cua `exec` (chay lai moi lan reload): Tab+r la
-- phim dung thuong xuyen, de `exec` thi moi lan bam se chong them mot swaybg,
-- mot kanshi.
--
-- Idle & Lock giu swayidle/swaylock cua ban sway (quyet dinh 14/08/2026: KHONG
-- dung hypridle/hyprlock).
--
-- `autotiling` BO CO Y: dwindle tu chon huong chia theo ti le cua so, giu lai la
-- chay mot daemon khong lam gi. (No la goi rieng cua sway, xem sway/default.nix.)
--
-- `hl.exec_cmd` (cap dinh) CHAY lenh ngay. Dung nham `hl.dsp.exec_cmd` (cap
-- dispatcher) thi khong co gi chay ca: no chi TAO ra mot closure de gan vao
-- keybind, va o day khong ai gan.
-- =============================================================================
hl.on("hyprland.start", function()
	hl.exec_cmd(table.concat({
		"swayidle -w",
		"timeout 900 'swaylock -f'",
		"timeout 1800 '" .. dpmsOff .. "'",
		"resume '" .. dpmsOn .. "'",
		"before-sleep 'swaylock -f'",
	}, " "))

	hl.exec_cmd("mako")
	hl.exec_cmd("swaybg -i ~/.nix/home-manager/dotfiles/images/nix-waifu.png -m fill")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("kanshi")
	hl.exec_cmd("fcitx5 -rd")
end)

-- sway dung `bindswitch`. TEN THIET BI phai khop thu `hyprctl devices` in ra
-- tren chinh rog — kiem tai may, dung chep tu tai lieu. `switch:` la mot
-- "special sym" nen ca cum (ke ca dau cach trong "Lid Switch") di thang vao
-- ten phim, khong bi doi thanh keysym.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

-- =============================================================================
-- Power
-- =============================================================================
hl.bind(modAlt .. " + L", hl.dsp.exec_cmd("swaylock"))
hl.bind(
	modAlt .. " + SHIFT + L",
	hl.dsp.exec_cmd(
		[[echo -e 'Yes\nNo' | rofi -dmenu -p 'Exit hyprland session?' | grep -q Yes && hyprctl dispatch "hl.dsp.exit()"]]
	)
)
hl.bind(
	modAlt .. " + SHIFT + R",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Reboot the system?' | grep -q Yes && systemctl reboot]])
)
hl.bind(
	modAlt .. " + SHIFT + S",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Shutdown the system?' | grep -q Yes && systemctl poweroff]])
)
hl.bind(
	modAlt .. " + SHIFT + H",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Hibernate the system?' | grep -q Yes && systemctl hibernate]])
)

-- =============================================================================
-- Input
-- sway co ba khoi rieng (type:keyboard / type:touchpad / type:pointer);
-- hyprland gop thanh mot. `pointer_accel` -> `sensitivity`, `dwt` ->
-- `disable_while_typing`, `middle_emulation` -> `middle_button_emulation`.
-- Sway dat accel rieng cho touchpad (-0.3) va pointer (-0.2); o day chi co mot
-- `sensitivity` chung. Muon tach thi phai dung `hl.device({ name = ... })` voi
-- ten lay tu `hyprctl devices` — de lai lam sau khi ngoi truoc may.
-- `scroll_method two_finger` khong co doi ung: hyprland khong co khoa do, va
-- libinput mac dinh cho touchpad da la two-finger.
--
-- LUU Y ten khoa: hyprlang viet `tap-to-click` (gach ngang), ban Lua viet
-- `tap_to_click` (gach duoi). CConfigManager::luaConfigValueName doi `:` thanh
-- `.` va `-` thanh `_` cho MOI ten khoa, nen day la luat chung chu khong phai
-- ngoai le cua rieng khoa nay. Viet nham thi vao `hyprctl configerrors` chu
-- khong lam hong config.
-- =============================================================================
hl.config({
	input = {
		repeat_rate = 30,
		repeat_delay = 300,
		sensitivity = -0.2,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			disable_while_typing = true,
			middle_button_emulation = true,
		},
	},
})

-- =============================================================================
-- Launchers (rofi)
-- =============================================================================
hl.bind(mod .. " + D", hl.dsp.exec_cmd("rofi -normal-window -show drun"))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("rofi -normal-window -show combi"))
hl.bind(alt .. " + Tab", hl.dsp.exec_cmd("rofi -normal-window -show window"))
