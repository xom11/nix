-- Dich tay tu sway.d/conf.d/shortcuts.conf.

local vars = require("vars")
local mod, alt = vars.mod, vars.alt

-- Ban sway co bien `$notify-...`; ban hyprlang CO Y khong dinh nghia bien tuong
-- duong, vi gia tri chua `$(...)` va hanh vi cua bo phan tich bien hyprlang voi
-- chuoi do la thu chua ai do o day. Ly do do KHONG con o ban Lua: khong co lop
-- thay the bien nao ca, `..` chi la noi chuoi va `[[...]]` khong dien giai bat
-- cu ky tu nao ben trong (ke ca `$`, `\` hay dau nhay).
local function notify(tag, cmd)
	return ([[notify-send -h string:x-canonical-private-synchronous:%s -t 2000 "$(%s)"]]):format(tag, cmd)
end

local getVol = "wpctl get-volume @DEFAULT_AUDIO_SINK@"
local getMic = "wpctl get-volume @DEFAULT_AUDIO_SOURCE@"
local getBr = "brightnessctl -m"

-- Am luong / do sang.
--   hyprlang `bindel` = bind + e (lap khi giu) + l (chay ca khi khoa man)
--                     -> { repeating = true, locked = true }
--   hyprlang `bindl`  = chi l -> { locked = true }
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd([[wpctl set-volume --limit 2.0 @DEFAULT_AUDIO_SINK@ 10%+ && ]] .. notify("vol", getVol)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd([[wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- && ]] .. notify("vol", getVol)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ]] .. notify("vol", getVol)),
	{ locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ]] .. notify("mic", getMic)),
	{ locked = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd([[brightnessctl set 10%+ && ]] .. notify("br", getBr)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd([[brightnessctl set 10%- && ]] .. notify("br", getBr)),
	{ locked = true, repeating = true }
)

-- sway: `floating_modifier $mod normal`. hyprlang `bindm` -> `{ mouse = true }`.
-- Hai dispatcher nay khong nhan tham so: `window.drag()` va `window.resize()`
-- goi tran chinh la ban "keo bang chuot" (`resize` co tham so x/y thi thanh
-- resizeactive, xem submap ben duoi).
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Clipboard manager
hl.bind(
	alt .. " + V",
	hl.dsp.exec_cmd([[cliphist list | rofi -normal-window -dmenu | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl]])
)

-- Focus. `hl.focus` phan biet y dinh bang TEN TRUONG chu khong bang thu tu
-- tham so: direction / monitor / workspace / window / last. Chu cai cu cua
-- hyprlang (l/d/u/r) van duoc chap nhan, nhung viet du chu cho ro.
hl.bind(mod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + Right", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))

-- `fullscreen, 0` cua hyprlang = che do fullscreen that (1 la maximize).
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))

-- sway co `focus parent`; dwindle khong co container cha de focus, nen
-- `group.toggle` la thu gan nhat ve cong dung (gom cua so lai thanh mot tab).
hl.bind(mod .. " + A", hl.dsp.group.toggle())

-- sway lam hai viec (`move container ...; workspace ...`); `window.move` da bao
-- gom ca chuyen theo. Muon kieu "silent" (khong nhay theo) thi them
-- `follow = false` — o day cu y KHONG them.
for i = 1, 4 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- sway tach `reload` va `restart`; hyprland khong co khai niem restart rieng.
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- sway dung `mode "resize"`, hyprland dung submap. Khac nhau ve ngu nghia:
-- `mode` cua sway bat het ban phim, con submap chi bat lai dung nhung phim no
-- tu dinh nghia -- mot phim la ngoai du kien go trong luc resize se roi thang
-- vao cua so dang focus thay vi bi nuot. Ca ba loi thoat (Return, Escape,
-- $mod+R) deu co san nen khong bi ket, nhung neu sau nay can chan het thi them
-- `hl.bind("catchall", hl.dsp.no_op())` (chua them o day, de danh gia tren may
-- that; `catchall` chi hop le BEN TRONG submap).
--
-- `hl.define_submap` khong "mo mot che do" luc chay -- no chi dat mot bien
-- trang thai trong config manager trong luc goi ham, nen moi `hl.bind` ben
-- trong duoc gan vao submap "resize". Vao submap bang `hl.dsp.submap("resize")`,
-- ra bang `hl.dsp.submap("reset")` ("reset" va chuoi rong deu la ten dac biet,
-- xem Actions::setSubmap).
hl.bind(mod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
	-- hyprlang `binde` = lap khi giu -> { repeating = true }.
	-- `resizeactive -10 0` la DELTA, doi ung `relative = true`; bo truong do
	-- di la thanh dat kich thuoc TUYET DOI.
	hl.bind("J", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("L", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("semicolon", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("Left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("Right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })

	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("Escape", hl.dsp.submap("reset"))
	hl.bind(mod .. " + R", hl.dsp.submap("reset"))
end)
