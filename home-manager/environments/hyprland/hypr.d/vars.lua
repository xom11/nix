-- Bien dung chung cho ca cay config, thay cho `$mod`/`$alt`/`$tab` cua hyprlang.
--
-- PHAI la mot module chu khong the la bien toan cuc nhu ban hyprlang: moi file
-- duoc `require` la mot chunk Lua rieng, `local` khong xuyen qua bien gioi file.
--
-- `require("vars")` giai duoc vi Hyprland tu dat `package.path` =
-- `<thu muc chua config chinh>/?.lua`, tuc `~/.config/hypr/vars.lua`
-- (src/config/lua/ConfigManager.cpp: `configDir / "?.lua"`). File nao duoc
-- require deu vao danh sach theo doi cua config watcher, nen sua file nay cung
-- kich hoat reload y het cac file khac.

return {
	mod = "SUPER",
	alt = "ALT",

	-- hyprlang: `$tab = SUPER CTRL SHIFT` — modifier noi bang DAU CACH.
	-- `hl.bind` thi tach chuoi phim bang DAU CONG (parseKeyString dung
	-- CVarList2(sv, 0, '+')), nen o day phai la ` + `. Viet nham dau cach se
	-- ra loi "Unknown keysym: ..., did you forget a +?".
	tab = "SUPER + CTRL + SHIFT",
}
