--- === LangSwitch ===
---
--- Đổi thẳng sang một chế độ gõ cụ thể, mỗi ngôn ngữ một phím — không phải vòng qua lại như
--- phím đổi bộ gõ mặc định của macOS.
---
--- Tách từ Tab.spoon.
---
--- Việc đổi giao hẳn cho `tongue`, không tự gọi hs.keycodes nữa. Một "chế độ" thật ra là HAI
--- cần gạt — layout hệ thống và bộ gõ tiếng Việt — mà hs.keycodes chỉ với tới cần thứ nhất.
--- Bản cũ đặt `en` = layout Unicode Hex Input rồi trông cậy vào việc GoNhanh không đụng tới
--- layout đó; đúng được là nhờ may. `tongue en` gạt cả hai (chọn ABC, tắt GoNhanh) rồi đọc
--- lại máy để chắc chắn nó đã đổi thật mới báo thành công.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("LangSwitch"):bindHotkeys({
---     zh = { tab, "q" },
---     vi = { tab, "w" },
---     en = { tab, "e" },
--- })
--- ```

local obj = {}
obj.__index = obj

obj.name = "LangSwitch"
obj.version = "2.0"
obj.author = "kln"
obj.license = "MIT"

local log = hs.logger.new("LangSwitch", "info")

--- LangSwitch.modes
--- Variable
--- Các chế độ `tongue` hiểu.
---
--- Không còn bảng sourceID ở đây. Bản đồ chế độ -> (layout, bộ gõ) nay nằm trong tongue và
--- ~/.config/tongue/config.toml, nên chỉ còn đúng một nơi biết ID của Apple; đổi bộ gõ khác
--- là sửa config, không phải sửa spoon. Tên chế độ cũng chính là thứ LanguageMemory ghi vào
--- ~/.hammerspoon/LanguageMemory.json, nên hai chỗ vẫn nói cùng một thứ tiếng.
obj.modes = { "vi", "en", "zh" }

-- ──────────────────────────────────────────────
-- Tìm binary
-- ──────────────────────────────────────────────

-- Hammerspoon là app GUI: PATH của nó do launchd cấp và chỉ có
-- /usr/bin:/bin:/usr/sbin:/sbin — không thấy profile của Nix. hs.task thì lại đòi đường dẫn
-- tuyệt đối. Nên hỏi shell đăng nhập đúng MỘT lần rồi nhớ lại, thay vì ghim cứng đường dẫn:
-- máy khác cài tongue ở chỗ khác, và đường dẫn store còn đổi sau mỗi lần nâng cấp.
local binary = nil
local waiting = {}

-- Shell đăng nhập có thể lẫn escape của prompt vào stdout (powerlevel10k phát chuỗi đổi hình
-- con trỏ ngay khi khởi động), nên bóc lấy đúng đoạn đường dẫn chứ không tin nguyên dòng.
--
-- Lấy TOKEN CUỐI của dòng, đừng dùng `.*(/[^%s]*/tongue)$`: `.*` tham lam nên nó nuốt gần hết
-- dòng rồi chừa lại đoạn khớp NGẮN NHẤT — "/etc/profiles/.../bin/tongue" ra thành "/bin/tongue",
-- một đường dẫn không tồn tại nhưng trông đủ hợp lý để lọt qua mọi kiểm tra hình thức.
-- Kiểm luôn file có thật: thà dò lại còn hơn nhớ một đường dẫn hỏng cho tới lần reload sau.
local function parseBinary(out)
    for line in (out or ""):gmatch("[^\r\n]+") do
        local token = line:gsub("%c", ""):match("([^%s]+)%s*$")
        if token and token:match("/tongue$") and hs.fs.attributes(token, "mode") == "file" then
            return token
        end
    end
    return nil
end

-- /bin/zsh chứ không phải $SHELL: env của tiến trình GUI thường không có SHELL, mà /bin/zsh
-- thì macOS nào cũng có. -l để nạp profile (chỗ PATH của Nix được thêm vào), không -i để khỏi
-- kéo theo cả cấu hình shell tương tác.
local function withBinary(fn)
    if binary then
        return fn(binary)
    end
    table.insert(waiting, fn)
    if #waiting > 1 then
        return -- đã có một lượt dò đang chạy, cứ xếp hàng
    end
    hs.task.new("/bin/zsh", function(_, out)
        binary = parseBinary(out)
        local work = waiting
        waiting = {}
        if not binary then
            hs.alert.show("LangSwitch: không tìm thấy `tongue` trong PATH", 3)
            log.e("không tìm thấy tongue — đã cài và rebuild chưa?")
            return -- waiting đã rỗng nên lần bấm phím sau sẽ dò lại
        end
        log.i("tongue: " .. binary)
        for _, f in ipairs(work) do
            f(binary)
        end
    end, { "-lc", "command -v tongue" }):start()
end

-- ──────────────────────────────────────────────
-- Đổi chế độ
-- ──────────────────────────────────────────────

local listeners = {}

local function run(mode, notify)
    if not mode then
        return
    end
    withBinary(function(bin)
        local task = hs.task.new(bin, function(code, _, stderr)
            if code ~= 0 then
                hs.alert.show("Không đổi được chế độ gõ: " .. mode, 2)
                log.e(string.format("tongue %s -> exit %d: %s", mode, code, stderr or ""))
                return
            end
            if not notify then
                return
            end
            for _, fn in ipairs(listeners) do
                local ok, err = pcall(fn, mode)
                if not ok then
                    log.e("listener lỗi: " .. tostring(err))
                end
            end
        end, { mode })
        -- hs.task.new trả nil khi đường dẫn không chạy được. Không bắt ở đây thì `:start()`
        -- ném lỗi index-nil vào console rồi phím tắt lặng thinh — đúng cách hỏng khó lần ra
        -- nhất: bấm phím, không có gì xảy ra, không có gì báo.
        if not task then
            binary = nil -- ép dò lại ở lần sau
            hs.alert.show("LangSwitch: không chạy được " .. bin, 3)
            log.e("hs.task.new trả nil cho " .. bin)
            return
        end
        task:start()
    end)
end

--- LangSwitch:switch(mode)
--- Method
--- Đổi chế độ vì NGƯỜI DÙNG yêu cầu, rồi báo cho các listener.
---
--- Chỉ dùng cho hành động có chủ đích (phím tắt). Khôi phục tự động phải đi qua :apply().
function obj:switch(mode)
    run(mode, true)
    return self
end

--- LangSwitch:apply(mode)
--- Method
--- Đổi chế độ nhưng KHÔNG báo listener — dành cho khôi phục tự động.
---
--- Tách riêng khỏi :switch() để chặn vòng lặp học-lại-chính-mình từ gốc: nếu khôi phục cũng
--- phát tín hiệu, LanguageMemory sẽ học lại đúng thứ nó vừa đặt, mà lệnh chạy mất ~200ms nên
--- lúc tín hiệu về, app đang focus có thể đã là app khác — tức là gán nhầm chế độ của app cũ
--- cho app mới. Bản cũ phải dựng cờ `applied` để lọc tiếng vọng đó; hai lối vào thì không cần.
function obj:apply(mode)
    run(mode, false)
    return self
end

--- LangSwitch:onModeChange(fn)
--- Method
--- Đăng ký hàm chạy sau mỗi lần :switch() thành công, nhận tên chế độ.
---
--- Đây là kênh DUY NHẤT biết được người dùng vừa đổi chế độ. hs.keycodes.inputSourceChanged
--- không thay thế được: với bộ gõ ngoài, `vi` và `en` dùng CHUNG một input source (ABC) — thứ
--- phân biệt là bộ gõ bật hay tắt — nên macOS không phát sự kiện nào khi đổi vi <-> en.
function obj:onModeChange(fn)
    table.insert(listeners, fn)
    return self
end

function obj:bindHotkeys(mapping)
    local spec = {}
    for _, mode in ipairs(obj.modes) do
        spec[mode] = function()
            obj:switch(mode)
        end
    end
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

return obj
