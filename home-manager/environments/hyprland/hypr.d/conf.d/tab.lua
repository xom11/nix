-- Dich tay tu sway.d/conf.d/tab.conf. `$tab` dinh nghia o vars.lua.

local tab = require("vars").tab

-- Pin. Ban sway hardcode `battery_qcom_battmgr_bat` — do la pin cua a14
-- (Snapdragon), tren rog (Intel) khong ton tai nen phim se in ra rong. Do bang
-- `upower -e` cho khong phu thuoc may.
hl.bind(
	tab .. " + P",
	hl.dsp.exec_cmd(
		[[notify-send -t 2000 "$(upower -i "$(upower -e | grep -m1 battery)" | awk '/state:/{s=$2} /percentage:/{p=$2} /energy-rate:/{w=$2} END{printf "%s %s %.1fW", s, p, w}')"]]
	)
)

-- Gio
hl.bind(tab .. " + T", hl.dsp.exec_cmd([[notify-send -t 2000 "$(date +'%H:%M:%S - %d/%m/%Y')"]]))

-- Reload. `hyprctl reload` van la lenh rieng cua hyprctl chu khong di qua
-- `dispatch`, nen no KHONG bi doi cu phap khi chuyen sang Lua (khac hai lenh
-- `hyprctl dispatch` trong system.lua).
hl.bind(tab .. " + R", hl.dsp.exec_cmd([[hyprctl reload && notify-send -t 2000 "Hyprland config reloaded"]]))

-- Bo go: tieng Viet (lotus) / English (keyboard-us)
hl.bind(tab .. " + W", hl.dsp.exec_cmd([[fcitx5-remote -s lotus && notify-send -t 2000 "Tiếng Việt"]]))
hl.bind(tab .. " + E", hl.dsp.exec_cmd([[fcitx5-remote -s keyboard-us && notify-send -t 2000 "English"]]))

-- Chup man hinh. Ban sway co them `echo -n /tmp/ss.png | wl-copy` o dau — ve do
-- chep DUONG DAN roi bi ve sau ghi de ngay bang ANH, nen bo.
--
-- Ban hyprlang lap lai NGUYEN VAN lenh nay o ca hai binding thay vi gom vao mot
-- bien `$screenshot`, vi gia tri chua `$(slurp)` va hanh vi cua bo phan tich
-- bien hyprlang voi chuoi do la thu chua ai do o day. Ly do do khong con: `local`
-- cua Lua khong phai lop thay the van ban, no chi la mot bien giu chuoi.
local screenshot =
	[[grim -g "$(slurp)" /tmp/ss.png && wl-copy < /tmp/ss.png && notify-send -t 2000 "Screenshot copied to clipboard"]]

hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind(tab .. " + S", hl.dsp.exec_cmd(screenshot))
