--- === LanguageMemory ===
---
--- Tự động nhớ và khôi phục input source cho từng application (giống fcitx5).
--- Khi focus app X, tự động switch về input source đã dùng lần cuối cho app X.
---
--- 2 chế độ:
--- 1. Học tự động — quan sát khi user đổi input source, ghi nhớ app → sourceID
--- 2. Config thủ công — dùng setApplications(), ưu tiên hơn học tự động
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
obj.version = "1.0"
obj.author = "kln"
obj.homepage = "https://github.com/kln/nix"
obj.license = "MIT"

local log = hs.logger.new("LanguageMemory", "debug")

-- ──────────────────────────────────────────────
-- Lưu trữ: appName → sourceID
-- ──────────────────────────────────────────────

local memory = {}
local overrides = {}
local memoryFile = hs.configdir .. "/LanguageMemory.json"

local appWatcher
local wakeWatcher

-- Tiến trình giả của hệ thống: chúng phát sự kiện `activated` như app thật nên vẫn bị học,
-- nhưng nhớ input source cho chúng thì vô nghĩa. Bằng chứng: LanguageMemory.json trên máy
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

-- Ghi nhớ đúng lần đổi mà CHÍNH TA vừa gây ra, để bỏ qua tiếng vọng của nó.
--
-- onAppFocus gọi setSource() → macOS phát inputSourceChanged → onInputChange chạy và đọc
-- frontmostApplication(). Nếu không chặn, ta học lại chính giá trị mình vừa đặt, và trong lúc
-- chuyển app nhanh thì app đọc được có thể đã là app kế tiếp — tức là gán nhầm nguồn của app
-- cũ cho app mới.
--
-- Cố ý KHÔNG dùng cửa sổ thời gian (kiểu chặn học trong 0,5 s sau mỗi lần focus): làm vậy sẽ
-- nuốt luôn lần đổi hợp lệ nếu user bấm tab+w ngay sau khi chuyển app — đổi một lỗi hiếm lấy
-- một lỗi thường gặp hơn. So khớp cả app lẫn sourceID thì chính xác và không có tác dụng phụ.
local applied = nil

-- ──────────────────────────────────────────────
-- Helper: chuyển sourceID → setLayout/setMethod
-- ──────────────────────────────────────────────

-- Set input source từ sourceID.
--
-- Không cache layouts/methods nữa: cache chỉ dựng 1 lần lúc start, nên input
-- source bật thêm sau đó sẽ *học* được (onInputChange không check cache) nhưng
-- không bao giờ *khôi phục* được — triệu chứng "nhớ ngôn ngữ nhưng không tự
-- chuyển". hs.keycodes.currentSourceID nhận cả layout lẫn method, nên hai nhánh
-- kia vốn cũng trả về y hệt nhau.
local function setSource(sourceID)
    return hs.keycodes.currentSourceID(sourceID)
end

-- ──────────────────────────────────────────────
-- Persist
-- ──────────────────────────────────────────────

local function save()
    hs.json.write(memory, memoryFile, false, true)
end

local function load()
    local data = hs.json.read(memoryFile)
    if data then
        memory = data
        -- Dọn các mục đã lỡ học trước khi có BLACKLIST, để file tự lành thay vì bắt user
        -- chạy :forget() bằng tay.
        local dropped = 0
        for name in pairs(BLACKLIST) do
            if memory[name] then
                memory[name] = nil
                dropped = dropped + 1
            end
        end
        if dropped > 0 then
            save()
            log.i(string.format("Đã bỏ %d mục pseudo-app khỏi bộ nhớ", dropped))
        end
        return true
    end
    memory = {}
    return false
end

-- ──────────────────────────────────────────────
-- Logic chính
-- ──────────────────────────────────────────────

-- Khi app A được focus: restore ngay lập tức
local function onAppFocus(appName)
    if not appName then return end
    if BLACKLIST[appName] then return end

    local sid = overrides[appName] or memory[appName]
    if not sid then return end

    -- Đã đúng nguồn rồi thì không đụng vào. Nhờ vậy `applied` chỉ được đặt khi thật sự có
    -- thay đổi, nên chắc chắn sẽ có đúng một sự kiện inputSourceChanged theo sau để tiêu thụ
    -- nó — không có chuyện cờ còn treo lơ lửng tới lần đổi hợp lệ sau đó.
    if hs.keycodes.currentSourceID() == sid then return end

    applied = {app = appName, sid = sid}
    setSource(sid)
end

-- Khi user đổi input source: học ngay
local function onInputChange()
    -- Tiêu thụ cờ ngay đầu hàm: nó chỉ được sống qua đúng một sự kiện.
    local echo = applied
    applied = nil

    local app = hs.application.frontmostApplication()
    if not app then return end
    local name = app:name()
    if not name then return end

    if BLACKLIST[name] then return end
    if overrides[name] then return end  -- không ghi đè config thủ công

    local sid = hs.keycodes.currentSourceID()
    if not sid then return end

    -- Tiếng vọng của chính lần restore vừa rồi, không phải user đổi.
    if echo and echo.app == name and echo.sid == sid then return end

    if memory[name] == sid then return end  -- không đổi

    memory[name] = sid
    save()
    log.d("Learned: " .. name .. " → " .. sid)
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

    -- Watch app focus
    appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.activated then
            onAppFocus(name)
        end
    end)
    appWatcher:start()

    -- Watch input source change → học
    --
    -- CHÚ Ý: hs.keycodes.inputSourceChanged chỉ có MỘT slot toàn cục — nó gọi
    -- keycodes._callback:_stop() rồi thay bằng callback mới. Đừng đăng ký ở chỗ nào khác,
    -- nếu không cái đăng ký sau sẽ âm thầm gỡ cái này (GoNhanh.spoon từng làm đúng vậy).
    hs.keycodes.inputSourceChanged(onInputChange)

    -- Chỉ riêng `activated` là không đủ: sau khi máy ngủ dậy hoặc mở khoá màn hình, app đang
    -- focus không phát `activated` lần nữa, nên nguồn nhập vẫn là cái mà loginwindow để lại.
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
    applied = nil
    log.i("Stopped")
    return self
end

function obj:setup(config)
    if config then
        if config.applications then
            for name, sid in pairs(config.applications) do
                overrides[name] = sid
                memory[name] = sid
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