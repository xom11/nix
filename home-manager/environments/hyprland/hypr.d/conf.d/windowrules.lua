-- Moi cua so TILING moi mo ra deu roi vao workspace TRONG co so thap nhat.
-- Doi ung ben sway la sway.d/scripts/new-workspace.sh (sway khong co rule nao
-- tuong duong -- xem ghi chu trong file do).
--
-- Vi sao lai muon the: launcher la beckon, va beckon la focus-or-launch. Bam
-- Cap+b lan dau thi Brave duoc LAUNCH -> cua so moi -> rule nay day no sang mot
-- workspace rieng. Bam lan sau thi beckon FOCUS cua so cu -> compositor tu nhay
-- sang dung workspace do. Ket qua: moi app mot workspace, va dieu huong bang
-- phim app chu khong bang so workspace. ($mod+1..4 trong shortcuts.lua thanh
-- gan nhu thua, co y de nguyen.)
--
-- CU PHAP: ban Lua tach hai nua ra thanh hai cho ro rang, thay vi mot chuoi
-- phang nhu hyprlang. `match` la dieu kien khop, con moi khoa khac o cap ngoai
-- la HANH DONG. Doi ung:
--   hyprlang: windowrule = match:class .*, match:float false, workspace emptym
--   lua:      match = { class = ".*", float = false }, workspace = "emptym"
-- Ten cua ca hai nua deu duoc kiem: `match` sai ten -> "unknown match property",
-- hanh dong sai ten -> "unknown field". Ca hai vao `hyprctl configerrors`.
--
-- `name` la tuy chon nhung nen co: `hl.window_rule` nhan dien rule THEO TEN, nen
-- rule co ten duoc SUA TAI CHO khi reload thay vi de lai ban cu.
--
-- `emptym` = workspace trong dau tien tren MAN HINH hien tai. Khong dung
-- `emptynm`: chu `n` bat no lay cai trong ke tiep SAU workspace dang dung, nen
-- cua so dau tien cua phien (luc workspace 1 con trong) van bi day sang 2 va
-- workspace 1 bien mat -- xem hyprwm/Hyprland#7153. `m` thi hien tai vo nghia vi
-- rog chi bat mot man (hyprland.lua tat eDP-1), nhung dung khi nao cam lai man
-- thu hai.
--
-- CANH BAO ve pham vi kiem: `--verify-config` chi kiem TEN, khong kiem GIA TRI.
-- Da do o thoi hyprlang: `workspace emptyZZZ` cung tra ve `config ok`. Ban Lua
-- khong khac o diem nay. Nghia la gia tri `emptym` va hanh vi cua
-- `float = false` voi dialog CHUA duoc chung minh o day, phai ngoi truoc may xem.
--
-- `float = false` de dialog (Save As, file picker, popup) o nguyen tai cho thay
-- vi bay sang workspace rieng.
hl.window_rule({
	name = "new-window-to-empty-workspace",
	match = { class = ".*", float = false },
	workspace = "emptym",
})
