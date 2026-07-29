--- === LanguageMemory ===
---
--- Tự động nhớ và khôi phục chế độ gõ cho từng application (giống fcitx5).
--- Khi focus app X, tự động chuyển về chế độ đã dùng lần cuối cho app X.
---
--- 2 chế độ:
--- 1. Học tự động — ghi nhớ app → chế độ mỗi khi user bấm phím đổi ngôn ngữ
--- 2. Config thủ công — dùng setup(), ưu tiên hơn học tự động
---
--- Đơn vị lưu trữ là CHẾ ĐỘ của tongue ("vi"/"en"/"zh"), không phải sourceID nữa. Việc đổi
--- giao cho LangSwitch, tức là cho tongue — xem lý do ở onUserSwitch bên dưới.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("LanguageMemory")
--- spoon.LanguageMemory:start()
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "LanguageMemory"
obj.version = "2.0"
obj.author = "kln"
obj.homepage = "https://github.com/kln/nix"
obj.license = "MIT"

local log = hs.logger.new("LanguageMemory", "debug")

-- ──────────────────────────────────────────────
-- Lưu trữ: appName → mode
-- ──────────────────────────────────────────────

local memory = {}
local overrides = {}
local memoryFile = hs.configdir .. "/LanguageMemory.json"

local langSwitch
local appWatcher
local wakeWatcher
local listening = false

local VALID_MODE = { vi = true, en = true, zh = true }

-- Bộ nhớ đời trước lưu sourceID. Quy ước cũ của repo: ABC = tiếng Việt (GoNhanh chạy nền),
-- Unicode Hex Input = tiếng Anh. Chuyển đổi ngay lúc đọc để file tự lành, thay vì bắt user
-- xoá đi rồi dạy lại từ đầu.
local LEGACY_SOURCE = {
    ["com.apple.keylayout.ABC"] = "vi",
    ["com.apple.keylayout.UnicodeHexInput"] = "en",
    ["com.apple.inputmethod.SCIM.ITABC"] = "zh",
}

-- Tiến trình giả của hệ thống: chúng phát sự kiện `activated` như app thật nên vẫn bị học,
-- nhưng nhớ chế độ gõ cho chúng thì vô nghĩa. Bằng chứng: LanguageMemory.json trên máy
-- này đã có sẵn mục "loginwindow" (màn hình khoá) từ trước khi có danh sách này.
local BLACKLIST = {
    ["loginwindow"] = true,
    ["ScreenSaverEngine"] = true,
    ["Hammerspoon"] = true,
    ["Spotlight"] = true,
    ["SystemUIServer"] = true,
    ["Dock"] = true,
    ["universalaccessd"] = true,
    ["coreautha"] = true,
    ["SecurityAgent"] = true,
}

-- ──────────────────────────────────────────────
-- Persist
-- ──────────────────────────────────────────────

local function save()
    hs.json.write(memory, memoryFile, false, true)
end

local function load()
    local data = hs.json.read(memoryFile)
    if not data then
        memory = {}
        return false
    end
    memory = data

    -- Một vòng dọn duy nhất lo cả hai việc: bỏ pseudo-app đã lỡ học trước khi có BLACKLIST,
    -- và đổi sourceID đời cũ sang tên chế độ. Gán nil cho key ĐANG có là thao tác hợp lệ
    -- giữa vòng pairs (chỉ thêm key mới mới không được), nên xoá tại chỗ ở đây là an toàn.
    local changed = 0
    for name, value in pairs(memory) do
        if BLACKLIST[name] then
            memory[name] = nil
            changed = changed + 1
        elseif not VALID_MODE[value] then
            -- Không nhận ra thì bỏ hẳn: thà quên còn hơn khôi phục nhầm.
            memory[name] = LEGACY_SOURCE[value]
            changed = changed + 1
        end
    end
    if changed > 0 then
        save()
        log.i(string.format("Đã dọn/chuyển đổi %d mục trong bộ nhớ", changed))
    end
    return true
end

-- ──────────────────────────────────────────────
-- Logic chính
-- ──────────────────────────────────────────────

-- Khi app A được focus: khôi phục ngay.
--
-- Không hỏi "máy đang ở chế độ nào?" trước. Hỏi tốn thêm một tiến trình con, mà câu trả lời
-- có thể đã cũ ngay lúc ta hành động; trong khi `tongue <mode>` vốn đã idempotent — nó tự đọc
-- trạng thái thật, chỉ áp phần lệch, và đúng chế độ rồi thì không đụng gì cả.
local function onAppFocus(appName)
    if not appName then return end
    if BLACKLIST[appName] then return end

    local mode = overrides[appName] or memory[appName]
    if not mode then return end

    langSwitch:apply(mode)
end

-- Học từ chính hành động của người dùng (tab+q/w/e), không phải từ sự kiện của macOS.
--
-- Bắt buộc phải vậy: với bộ gõ ngoài thì `vi` và `en` dùng CHUNG một input source (ABC), thứ
-- phân biệt hai chế độ là bộ gõ đang bật hay tắt. macOS không phát inputSourceChanged cho lần
-- đổi đó, nên bản cũ — vốn học bằng cách nghe sự kiện ấy — sẽ mù đúng cái chuyển hay dùng
-- nhất, chỉ còn thấy mỗi lần sang tiếng Trung.
--
-- Đổi nguồn tín hiệu như vậy còn xoá luôn bài toán tiếng vọng: LangSwitch chỉ báo cho ta khi
-- CHÍNH người dùng bấm phím, còn lần khôi phục do ta gây ra đi qua :apply() và im lặng.
local function onUserSwitch(mode)
    local app = hs.application.frontmostApplication()
    if not app then return end
    local name = app:name()
    if not name then return end

    if BLACKLIST[name] then return end
    if overrides[name] then return end -- không ghi đè config thủ công
    if memory[name] == mode then return end

    memory[name] = mode
    save()
    log.d("Learned: " .. name .. " → " .. mode)
end

-- ──────────────────────────────────────────────
-- API
-- ──────────────────────────────────────────────

function obj:start()
    -- Gọi start() hai lần (file này tự start lúc load, mà docstring đầu file lại bảo user
    -- gọi :start()) sẽ ghi đè appWatcher và bỏ rơi cái cũ — nó vẫn chạy nhưng không ai tắt
    -- được nữa. Dọn trước cho chắc.
    self:stop()

    load()

    langSwitch = hs.loadSpoon("LangSwitch")

    -- Đăng ký đúng một lần cho mỗi phiên Lua: listener của LangSwitch chỉ có thêm chứ không
    -- gỡ được, nên start() lần hai sẽ khiến mỗi lần đổi chế độ gọi ta hai lượt. (Reload
    -- Hammerspoon dựng lại state mới nên cờ này tự về false, đúng như mong muốn.)
    if not listening then
        langSwitch:onModeChange(onUserSwitch)
        listening = true
    end

    -- Watch app focus
    appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.activated then
            onAppFocus(name)
        end
    end)
    appWatcher:start()

    -- Chỉ riêng `activated` là không đủ: sau khi máy ngủ dậy hoặc mở khoá màn hình, app đang
    -- focus không phát `activated` lần nữa, nên chế độ gõ vẫn là cái mà loginwindow để lại.
    -- Hoãn một nhịp để hệ thống ổn định trước khi đặt lại.
    wakeWatcher = hs.caffeinate.watcher.new(function(event)
        local w = hs.caffeinate.watcher
        if event == w.screensDidUnlock or event == w.systemDidWake then
            hs.timer.doAfter(0.5, function()
                local app = hs.application.frontmostApplication()
                if app and app:name() then
                    onAppFocus(app:name())
                end
            end)
        end
    end)
    wakeWatcher:start()

    log.i("Started")
    return self
end

function obj:stop()
    if appWatcher then
        appWatcher:stop()
        appWatcher = nil
    end
    if wakeWatcher then
        wakeWatcher:stop()
        wakeWatcher = nil
    end
    log.i("Stopped")
    return self
end

--- LanguageMemory:setup(config)
--- Method
--- config.applications: bảng appName -> chế độ ("vi"/"en"/"zh"), ưu tiên hơn phần tự học.
function obj:setup(config)
    if config then
        if config.applications then
            for name, mode in pairs(config.applications) do
                if VALID_MODE[mode] then
                    overrides[name] = mode
                    memory[name] = mode
                else
                    log.e(string.format("bỏ qua %s: chế độ không hợp lệ %q", name, tostring(mode)))
                end
            end
            save()
        end
        if config.memoryFile then
            memoryFile = config.memoryFile
            load()
        end
    end
    return self
end

function obj:forget(name)
    memory[name] = nil
    overrides[name] = nil
    save()
    return self
end

function obj:forgetAll()
    memory = {}
    overrides = {}
    save()
    return self
end

function obj:getMemory()
    return memory
end

-- Auto-start on load
pcall(function()
    obj:start()
end)

return obj
