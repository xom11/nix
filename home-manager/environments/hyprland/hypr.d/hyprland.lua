-- Dich tay tu sway.d/config. Bo phim giu NGUYEN nhu ban sway.
--
-- =============================================================================
-- VI SAO LA LUA CHU KHONG PHAI hyprland.conf
--
-- Tu Hyprland 0.55 hyprlang bi khai tu, config chinh la
-- `$XDG_CONFIG_HOME/hypr/hyprland.lua`. Hyprland tim Lua TRUOC, khong thay moi
-- lui ve `.conf` (src/config/ConfigManager.cpp, `Jeremy::getMainConfigPath`).
--
-- Cay `.conf` cu da XOA HAN 20/08/2026, sau khi mot phien dang nhap that xanh
-- het checklist o hosts/rog/README.md. Hau qua can nho: khong con gi de lui ve
-- nua, nen doi ten file nay KHONG con la duong thoat ma la mot cai bay —
-- khong thay file config nao ca thi Hyprland tu SINH RA mot stub, ngay tai
-- duong dan trong repo (xem muc cuoi file). Muon xem lai ban hyprlang thi lay
-- tu git: `git log --diff-filter=D -- '*/hypr.d/**/*.conf'`.
--
-- Day KHONG phai doi cu phap, ma la mot API khac han. Vai cho khac ve HANH VI
-- chu khong chi ve chinh ta, ghi ngay tai cho dung no:
--   * `hyprctl dispatch <X>` gio la `return hl.dispatch(<X>)` — xem conf.d/system.lua
--   * `hyprctl keyword` KHONG con chay — xem ghi chu cuoi file nay
--   * ten khoa config doi `-` thanh `_` — xem conf.d/system.lua (tap touchpad)
-- =============================================================================

-- =============================================================================
-- GPU render — BAT BUOC tren rog, khong phai tinh chinh.
--
-- Trieu chung khi thieu: re chuot bi giat. Nguyen nhan do 19/08/2026: HDMI cua
-- rog noi vao NVIDIA, nhung aquamarine chon Intel lam GPU chinh, nen moi khung
-- 4K duoc ve tren iGPU roi chep sang NVIDIA de xuat hinh
-- ("Buffer is marked as multigpu, forcing linear"). Rieng con tro thi hong han:
--   EGL (blit): glCheckFramebufferStatus failed: 1282
--   drm: Backend requires blit, but cursor blit failed
-- 85.848 lan trong 24 phut, va do duoc la no phat sinh THEO chuyen dong chuot.
--
-- Va day KHONG chi la mot cuoc dua luc khoi dong. Doc nguon aquamarine 0.13.0
-- (src/backend/drm/DRM.cpp), nhanh khi AQ_DRM_DEVICES khong duoc dat:
--     if (maxBuiltinPanelsGPU && devices.front() != maxBuiltinPanelsGPU) {
--         std::erase(devices, maxBuiltinPanelsGPU);
--         devices.push_front(maxBuiltinPanelsGPU);
--     }
-- No CO Y day GPU nao so huu man hinh gan lien (eDP/LVDS/DSI) len lam chinh.
-- Tren may nay eDP-1 thuoc Intel con NVIDIA khong co man gan lien nao — nen
-- Intel se LUON thang, ke ca sau khi da sua cuoc dua nap module. Vi vay dong
-- duoi day la bat buoc.
--
-- `/dev/dri/nvidia-card` la symlink do udev sinh, khai o hosts/rog/nvidia.nix.
-- Dung ten do chu KHONG dung `/dev/dri/card0` (so minor la ngau nhien) va KHONG
-- dung `/dev/dri/by-path/...` (AQ_DRM_DEVICES tach chuoi bang `:`, ma ten
-- by-path co san dau `:`).
--
-- Neu symlink khong ton tai, log se ghi "drm: Explicit device ... not found" va
-- Hyprland khong len — duong thoat la TTY (Ctrl+Alt+F2) roi go `Hyprland`.
--
-- VI SAO LIET KE CA HAI CARD, khong chi NVIDIA (sua 19/08/2026):
-- Ban dau day chi co `/dev/dri/nvidia-card`. Hyprland render dung tren NVIDIA,
-- nhung no khong con THAY eDP-1 nua — man do nam tren card Intel. Hau qua:
-- dong `hl.monitor({ output = "eDP-1", disabled = true })` ben duoi thanh DONG
-- CHET, va man laptop cu sang trung console text. Do: `card1-eDP-1
-- enabled=enabled dpms=On` trong khi `hyprctl monitors all` chi co HDMI-A-1.
--
-- THU TU LA THU QUAN TRONG, khong phai danh sach. Nguon aquamarine: khi
-- AQ_DRM_DEVICES duoc dat, no duyet dung THU TU minh viet va bo qua han doan
-- uu tien "GPU nao co man gan lien" (`maxBuiltinPanelsGPU`). Nen NVIDIA dung
-- truoc = NVIDIA lam primary = van render tren NVIDIA. Dao lai hai ve la quay
-- ve dung cai loi cu.
--
-- Khong ton them gi: eDP-1 bi tat ngay ben duoi nen khong co khung hinh nao
-- phai chep qua lai giua hai GPU. Kiem lai bang hai bo dem trong log —
-- `forcing linear` va `cursor blit failed` deu phai la 0.
--
-- `hl.env` goi thang setenv() luc CHAY file nay, tuc truoc khi backend DRM
-- dung len — dung thoi diem nhu `env =` cua hyprlang. Nhung cung y het no o
-- cho nay: `hyprctl reload` chay lai file nay va setenv lai, ma aquamarine da
-- doc bien tu lau roi. Doi gia tri nay thi phai KHOI DONG LAI phien.
-- =============================================================================
hl.env("AQ_DRM_DEVICES", "/dev/dri/nvidia-card:/dev/dri/intel-card")

-- =============================================================================
-- Man hinh -- rog chi dung man roi, man may TAT HAN (quyet dinh 14/08/2026:
-- may nay cam co dinh mot cho, khong mang di).
--
-- PHAI la `hl.monitor` native. kanshi KHONG lai duoc Hyprland -- do tren rog:
-- no in "applying profile 'docked'" roi `hyprctl monitors` khong doi gi ca,
-- ke ca sau khi giet ban kanshi cu va chay ban moi. Xanh gia hoan toan.
-- (kanshi van lo phan sway, xem wayland/kanshi.d/kanshi.conf.)
--
-- scale 2 la ti le NGUYEN nen net, cho 1920x1080 khong gian dung tren tam 4K.
-- Muon rong hon thi 1.5 (2560x1440).
--
-- Ca ba truong `mode`/`position`/`scale` la CHUOI, khong phai so — chung di
-- qua parseMode/parsePosition/parseScale nen nhan dung cu phap cu cua hyprlang
-- ("3840x2160@60", "0x0", "2", "auto", "preferred").
--
-- CANH BAO: tat eDP-1 o day la TINH. Hyprland khong co profile theo tap man
-- hinh nhu kanshi, nen rut HDMI ra la MAN HINH DEN o phien nay. Duong thoat:
-- dang nhap GNOME (mutter khong doc file nay lan kanshi, hai man chay binh
-- thuong), hoac sua qua SSH.
-- =============================================================================
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = "2" })
hl.monitor({ output = "eDP-1", disabled = true })

-- Glob, khong liet ke tay tung file -- doi ung cua `source = .../conf.d/*.conf`.
--
-- `require` cua Hyprland nhan glob, nhung CHI khi duong dan la tuong minh
-- (bat dau bang `~/`, `/`, `./` hoac `../`) VA co ky tu dai dien. Ten module
-- thuong ("conf.d/*") khong di qua nhanh do. Glob dung GLOB_TILDE nen `~` no.
--
-- Giong hyprlang, glob nay KHONG duoc khop 0 file: Hyprland bao
-- `module '...' not found: wildcard found no match`. An toan trong khi conf.d/
-- con it nhat mot file .lua. Ket qua duoc sort nen thu tu van la
-- shortcuts/system/tab/windowrules nhu cu.
require("~/.config/hypr/conf.d/*.lua")

-- Binding launcher sinh ra tu configs/shortcuts/apps.shared.toml.
-- Khong co duoi `.lua`: `require` tu them (resolveExplicitLuaRequireFile thu
-- lan luot BASE, BASE .. ".lua", BASE .. "/init.lua").
require("~/.config/hypr-nix/launch-app")

-- Ten khoa giong het hyprlang, chi khac hai cho: cap long nhau thanh bang long
-- nhau, va dau `-` trong ten doi thanh `_` (CConfigManager::luaConfigValueName
-- doi `:` -> `.` va `-` -> `_`). Khoa sai ten thi bao "unknown config key ..."
-- trong `hyprctl configerrors`, khong im lang.
hl.config({
	general = {
		border_size = 0,
		gaps_in = 0,
		gaps_out = 0,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
	},

	animations = {
		enabled = false,
	},

	-- sway.d co `xwayland disable`; ban do da doi thanh `enable` (14/08/2026) vi
	-- Zalo va vai Electron cu la X11-only. Giu cung mot quyet dinh o day.
	xwayland = {
		enabled = true,
	},
})

-- =============================================================================
-- BAY khi sua file trong cay nay (van con nguyen tu thoi .conf, chi doi cach go)
--
-- Xoa file config chinh la Hyprland SINH LAI STUB NGAY VAO REPO
-- (Config::initConfigManager -> generateDefaultConfig). `git checkout` /
-- `git pull` cap nhat bang unlink-roi-tao-moi nen thua cuoc dua voi watcher,
-- bao `unable to create file: File exists`, va phien dang chay tut con vai
-- binding. Truoc khi dung toi file trong `~/.config/hypr`, TAT AUTORELOAD.
--
-- Va day la cho cach go doi that: `hyprctl keyword` CHI chay voi parser cu
-- (HyprCtl.cpp: "keyword can't work with non-legacy parsers. Use eval."), nen
-- cau lenh cu KHONG con tac dung. Ban Lua la:
--
--     hyprctl eval 'hl.config({ misc = { disable_autoreload = true } })'
--
-- roi ghi DE TAI CHO (`git show HEAD:<path> > <path>`), khong unlink.
-- =============================================================================
