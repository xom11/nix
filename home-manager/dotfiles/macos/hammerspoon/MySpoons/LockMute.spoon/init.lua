--- === LockMute ===
---
--- Màn hình bị khoá thì mute output; đăng nhập lại trước máy thì trả đúng nguyên trạng.
---
--- Máy này bật 24/7 và phần lớn thời gian không có ai ngồi trước nó: để lâu không dùng thì màn
--- hình tự tắt rồi khoá, hoặc bị khoá bằng tay (cmd+alt+L của PowerManager.spoon). Việc code
--- vẫn diễn ra, nhưng qua SSH từ máy khác — nên mọi tiếng con máy phát ra trong lúc đó
--- (notification, chuông terminal, nhạc còn sót) chỉ làm phiền người ở cùng phòng, không ai
--- cần nghe.
---
--- SSH không sinh sự kiện unlock nào, nên phiên remote không bao giờ vô tình mở tiếng lại. Chỉ
--- lúc thật sự đăng nhập trước máy thì âm mới trở lại.
---
--- Phần notification khi khoá là việc riêng của macOS (System Settings → Notifications →
--- "Allow notifications when the screen is locked"/"when the display is sleeping"), spoon này
--- không chạm tới. Nó chỉ lo cái mà cài đặt kia không lo: tiếng.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("LockMute")
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "LockMute"
obj.version = "1.0"
obj.author = "kln"
obj.homepage = "https://github.com/kln/nix"
obj.license = "MIT"

local log = hs.logger.new("LockMute", "info")

-- Trạng thái âm thanh trước khi mute, lưu qua hs.settings chứ không phải một biến local.
--
-- hs.reload() (tab+r) dựng lại toàn bộ Lua state. Nếu bản lưu chỉ nằm trong biến local thì
-- reload đúng lúc đang khoá là mất hẳn: unlock sau đó không còn gì để trả về, máy im tiếng
-- vĩnh viễn mà không để lại dấu vết nào để lần ra. hs.settings ghi xuống plist nên sống sót
-- cả reload lẫn việc Hammerspoon bị kill.
local KEY = "LockMute.saved"

-- ──────────────────────────────────────────────
-- Trợ giúp
-- ──────────────────────────────────────────────

-- Session có đang khoá không. Hỏi thẳng hệ thống, không giữ cờ riêng — cùng lý do như
-- Caffeine:isOn(): một biến cờ sẽ lệch với thực tế ngay lần reload đầu tiên.
--
-- Khi session mở, macOS bỏ hẳn khoá CGSSessionScreenIsLocked khỏi bảng chứ không đặt nó bằng
-- false, nên phải kiểm tra theo kiểu truthy.
local function isLocked()
    local props = hs.caffeinate.sessionProperties()
    return (props ~= nil and props.CGSSessionScreenIsLocked) and true or false
end

-- Thiết bị output có thể đã đổi trong lúc khoá (rút tai nghe, đổi sang HDMI). Trả về đúng
-- thiết bị đã bị mute nếu nó còn đó; không thì đành dùng thiết bị mặc định hiện tại.
local function targetDevice(uid)
    if uid then
        local device = hs.audiodevice.findDeviceByUID(uid)
        if device then
            return device
        end
    end
    return hs.audiodevice.defaultOutputDevice()
end

-- ──────────────────────────────────────────────
-- Mute / trả âm
-- ──────────────────────────────────────────────

--- LockMute:quiet()
--- Method
--- Nhớ trạng thái âm thanh hiện tại rồi mute. Không làm gì nếu đang im rồi.
function obj:quiet()
    -- Nhiều sự kiện cùng dẫn tới một lần im: màn hình tắt (screensDidSleep) rồi vài giây sau
    -- mới khoá (screensDidLock). Lần thứ hai KHÔNG được ghi đè bản lưu, nếu không "trạng thái
    -- trước khi mute" thành muted=true và unlock sẽ không bao giờ mở tiếng lại.
    if hs.settings.get(KEY) then
        return self
    end

    local device = hs.audiodevice.defaultOutputDevice()
    if not device then
        log.w("không có output device, bỏ qua")
        return self
    end

    local saved = {
        uid = device:uid(),
        muted = device:muted() == true,
        volume = device:outputVolume(),
    }

    device:setMuted(true)

    -- Không phải thiết bị nào cũng cho mute: output qua HDMI/DisplayPort thường không có kênh
    -- mute và setMuted() lặng lẽ không làm gì, chỉ đọc lại mới biết. Hạ volume về 0 là cách
    -- duy nhất còn lại; volume cũ đã nằm trong bản lưu nên vẫn trả về được.
    if device:muted() ~= true then
        log.w("thiết bị không hỗ trợ mute, hạ volume về 0")
        device:setOutputVolume(0)
    end

    hs.settings.set(KEY, saved)
    log.f("im: %s (muted=%s volume=%s)", saved.uid, saved.muted, saved.volume)
    return self
end

--- LockMute:restore()
--- Method
--- Trả âm về đúng trạng thái đã nhớ. Không làm gì nếu không có gì để trả.
function obj:restore()
    local saved = hs.settings.get(KEY)
    if not saved then
        return self
    end

    -- Xoá bản lưu TRƯỚC khi chạm vào thiết bị: nếu phần dưới lỗi thì lần khoá sau vẫn nhớ lại
    -- được trạng thái thật, thay vì kẹt vĩnh viễn với một bản lưu cũ không ai xoá nổi.
    hs.settings.clear(KEY)

    local device = targetDevice(saved.uid)
    if not device then
        log.w("không tìm thấy output device để trả âm")
        return self
    end

    -- Đặt volume trong lúc còn mute, bỏ mute sau cùng: làm ngược lại thì có một khoảng thiết bị
    -- đã phát tiếng trong khi volume còn ở mức trung gian.
    if saved.volume then
        device:setOutputVolume(saved.volume)
    end
    device:setMuted(saved.muted == true)

    log.f("trả âm: %s (muted=%s volume=%s)", device:uid(), saved.muted, saved.volume)
    return self
end

-- ──────────────────────────────────────────────
-- Watcher
-- ──────────────────────────────────────────────

local w = hs.caffeinate.watcher

-- Có nhiều đường vào trạng thái "không ai ngồi trước máy", và không đường nào bao được đường
-- kia: để lâu không dùng thì màn hình tắt hoặc screensaver chạy trước, khoá đến sau (có khi
-- chậm vài phút, tuỳ grace period); khoá bằng tay thì screensDidLock bắn ngay mà màn hình
-- chưa tắt. Bắt hết cả bốn, quiet() tự lo chuyện trùng lặp.
local QUIET = {
    [w.screensDidLock] = true,
    [w.screensDidSleep] = true,
    [w.screensaverDidStart] = true,
    [w.systemWillSleep] = true,
}

-- Chiều ngược lại thì phải cẩn thận: "màn hình sáng lên" KHÔNG có nghĩa là bạn đã về. Chuột bị
-- ai đụng, hay máy tự thức để chạy việc nền, thì màn hình đăng nhập vẫn đứng đó — mở tiếng lúc
-- ấy đúng là cái cần tránh. Nên chỉ screensDidUnlock được trả âm vô điều kiện; ba sự kiện thức
-- còn lại phải kiểm tra session còn khoá hay không, chúng chỉ có ích cho trường hợp màn hình
-- tắt rồi sáng lại mà chưa kịp khoá.
local WAKE = {
    [w.screensDidUnlock] = "always",
    [w.screensDidWake] = "ifUnlocked",
    [w.screensaverDidStop] = "ifUnlocked",
    [w.systemDidWake] = "ifUnlocked",
}

local function onEvent(event)
    if QUIET[event] then
        obj:quiet()
        return
    end

    local mode = WAKE[event]
    if not mode then
        return
    end
    if mode == "ifUnlocked" and isLocked() then
        log.d("thức nhưng session còn khoá, giữ im")
        return
    end

    obj:restore()
end

function obj:init()
    -- Giữ watcher trên obj: watcher không còn ai tham chiếu sẽ bị garbage-collect và ngừng chạy
    -- trong im lặng (bài học đã ghi ở Caffeine.spoon).
    obj.watcher = w.new(onEvent):start()

    -- Hammerspoon có thể đã bị reload hoặc bị kill đúng lúc đang khoá: sự kiện unlock khi đó
    -- không ai nghe, bản lưu còn nguyên và máy sẽ im mãi. Lúc khởi động, nếu còn bản lưu treo
    -- mà session đã mở thì trả âm ngay.
    if hs.settings.get(KEY) and not isLocked() then
        log.i("còn trạng thái treo từ lần trước, trả âm")
        obj:restore()
    end

    return self
end

function obj:stop()
    if obj.watcher then
        obj.watcher:stop()
        obj.watcher = nil
    end
    return self
end

return obj
