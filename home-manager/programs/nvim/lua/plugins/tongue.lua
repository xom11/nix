-- Ép tiếng Anh ở Normal mode, khôi phục bộ gõ ở Insert mode.
--
-- Trước đây là extras/language-nvim.lua trong repo này. Tách ra thành plugin
-- công bố được vì nó giải một bài toán không repo cấu hình nào nên giữ riêng:
-- với bộ gõ tiếng Việt NGOÀI (GoNhanh/GoTiengViet/EVKey/OpenKey), `vi` và `en`
-- là CÙNG một input source `com.apple.keylayout.ABC` — thứ phân biệt là tiến
-- trình bộ gõ bật hay tắt, mà macOS không phơi ra thành input source. Sáu
-- plugin cùng mảng trên GitHub đều làm việc trên input-source ID nên không xử
-- lý được; `tongue` thì có.
--
-- Bản tách ra sửa bốn lỗi mà bản trong repo này vẫn còn, cả bốn đều đã tái hiện
-- được bằng thực nghiệm — xem README của plugin. Đáng nhớ nhất: `<C-c>` KHÔNG
-- bắn InsertLeave (`:help i_CTRL-C`), nên bản cũ để người dùng kẹt tiếng Việt ở
-- Normal mode vô thời hạn. Bản mới nghe ModeChanged.
--
-- Không cần guard theo OS: `nvim-pack-lock.json` cài plugin bất kể có gọi
-- vim.pack.add hay không (đã kiểm), nên guard chỉ tạo cảm giác an toàn giả.
-- Trên host không có `tongue` lẫn `fcitx5-remote`, và trong phiên SSH, plugin
-- tự resolve ra nil rồi nằm im — đúng thiết kế. `:checkhealth tongue` nói rõ
-- nó đang ở trạng thái nào và vì sao.
--
-- `backend` khai TƯỜNG MINH trên macOS, và đây không phải tối ưu vặt — không có
-- nó thì plugin nằm im hoàn toàn trên chính máy này. Auto-detect dừng lại khi
-- thấy phiên SSH, mà từ tongue.nvim `074695f` guard đọc cả ba biến
-- `SSH_TTY`/`SSH_CONNECTION`/`SSH_CLIENT` chứ không chỉ `SSH_TTY` như trước.
--
-- Trên macmini herdr server được sinh ra từ một phiên `ssh rog -> macmini`, nên
-- MỌI pane của nó thừa kế `SSH_CONNECTION` + `SSH_CLIENT` vĩnh viễn — kể cả khi
-- người dùng đang ngồi ngay trước máy và gõ qua kitty cục bộ. Biến đó là hoá
-- thạch của cách server khởi động, không phải mô tả ai đang gõ. Đo 17/08/2026:
-- nvim trong pane herdr có `SSH_CONNECTION`, KHÔNG có `SSH_TTY`, và
-- `:Tongue status` báo `enabled=false`. Chính comment trong `backend.lua` gọi
-- tên đúng ca này là cách duy nhất guard bắn nhầm.
--
-- Backend khai tường minh thắng guard đó (`pick()`: "wins outright, including
-- over SSH"). Chỉ khai khi binary có thật: `pkgs.tongue` chỉ có trên darwin, nên
-- host Linux vẫn đi auto-detect và tự chọn fcitx5-remote.
--
-- Nhưng "máy chạy nvim" và "máy giữ bàn phím" KHÔNG luôn là một. Với
-- `herdr --remote macmini`, nvim chạy trên macmini còn người dùng gõ ở rog, và
-- fcitx5 của rog biến phím thành tiếng Việt TRƯỚC khi byte đi qua SSH — nên
-- `tongue` ở đây đổi input source của macmini mà không ai thấy. Đo 19/08/2026:
-- nvim trên macmini nhảy `vi→en→vi` đủ bốn bước trong khi rog đứng im ở
-- `keyboard-us` suốt; focus event thì tới đủ, chỉ đích đến là sai máy.
--
-- `bin/ime-route` chuẩn hoá hai thế giới (`tongue` và `fcitx5-remote`) về chung
-- bảng từ vựng `en|vi|zh` rồi định tuyến sang đúng máy — đây là điểm mở rộng
-- được tongue.nvim thiết kế sẵn (hợp đồng 4 khoá), không phải lớp vá vòng.
-- `repoPath` luôn là `$HOME/.nix` (bất biến của repo này), nên đường dẫn viết
-- thẳng được; thiếu file thì rơi về hành vi cũ thay vì tắt hẳn plugin.
--
-- Từ tongue.nvim 1.3.0 (`:help tongue-backend-env`) upstream nêu HAI lối cho
-- backend phụ thuộc môi trường: script tự định tuyến, hoặc gọi lại `setup()`
-- mỗi khi câu trả lời đổi. Ở đây chọn lối thứ nhất, và lý do là tính ĐÚNG chứ
-- không phải tiện: `ime-route` chuẩn hoá về `en|vi|zh`, nên token đã nhớ vẫn
-- có nghĩa khi máy đổi. Lối `setup()` phải QUÊN layout đã nhớ mỗi lần gọi —
-- đúng với backend nói tiếng bản địa (`keyboard-us` của rog vô nghĩa trên
-- macmini), nhưng ở đây là mất trí nhớ không cần thiết.
--
-- Cái giá đã đo: phần phát hiện tốn 34 ms mỗi lời gọi (`ime-route get` đầy đủ
-- 84 ms, `tongue` cục bộ 33 ms). Đổi sang lối `setup()` sẽ dời 34 ms đó sang
-- mỗi lần FocusGained thay vì mỗi lời gọi. Chưa đáng: đường bất đồng bộ không
-- ai chờ, và đổi lấy nó là một autocmd nữa cộng nguy cơ quên layout sai lúc.
local route = vim.fn.expand("~/.nix/home-manager/programs/nvim/bin/ime-route")
local backend = nil
if vim.fn.has("mac") == 1 and vim.fn.executable("tongue") == 1 then
	if vim.fn.executable(route) == 1 then
		backend = {
			english = "en",
			get = { route, "get" },
			set = { route, "set" },
			-- Cả hai nhánh đều nói `unknown` khi không đọc được trạng thái:
			-- `tongue` khi live state không khớp mode nào, ime-route khi
			-- `fcitx5-remote -n` trả rỗng vì không có input context nào focus.
			unknown = "unknown",
			tokens = { "en", "vi", "zh" },
		}
	else
		backend = "tongue"
	end
end

-- `restore_on_unfocus` (tongue.nvim 1.2.0, mặc định TẮT ở thượng nguồn) trả bộ
-- gõ lại khi nvim thôi là nơi đang gõ. Bật ở đây vì trên máy này nvim gần như
-- luôn nằm trong một pane herdr: bộ gõ là trạng thái TOÀN CỤC của máy, nên nếu
-- không có nó, "ép tiếng Anh ở Normal mode" đi theo sang mọi tab khác — rời tab
-- nvim là kẹt tiếng Anh, không sự kiện nào bật tiếng Việt lại nữa.
--
-- Ba đường ra, chỉ một là focus event, và đã đo cả ba trên máy này (17/08/2026,
-- backend `tongue` thật, trong herdr thật): đổi pane và đổi tab đều sinh
-- FocusLost/FocusGained — herdr CÓ chuyển tiếp mode 1004 xuống pane — còn `<C-z>`
-- và `:q` thì KHÔNG sinh gì cả, vì terminal sở hữu pane vẫn giữ bàn phím suốt.
-- Hai đường sau plugin xử lý bằng `VimSuspend`/`VimLeavePre` và phải chặn, nên
-- `:q` tốn thêm ~200ms — đó là một lần gọi `tongue`, đổi lấy việc thoát nvim
-- không để lại bàn phím ở tiếng Anh.
vim.pack.add({ { src = "https://github.com/xom11/tongue.nvim" } }, { load = true, confirm = false })
require("tongue").setup({ backend = backend, restore_on_unfocus = true })
