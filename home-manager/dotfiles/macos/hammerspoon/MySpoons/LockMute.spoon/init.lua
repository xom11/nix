--- === LockMute ===
---
--- Mute on lock, restore exactly on unlock at the machine.
---
--- This box runs 24/7 with nobody in front of it most of the time, while work
--- continues over SSH -- so any sound it makes only bothers whoever is in the
--- room. SSH raises no unlock event, so a remote session can never un-mute it.
---
--- Whether notifications appear on the lock screen is a macOS setting; this only
--- handles what that setting does not: the sound.
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

-- In hs.settings, not a local: hs.reload() rebuilds all Lua state, so a reload
-- while locked would lose the saved state and mute the machine permanently with
-- no trace. hs.settings writes to a plist and survives reload and kill alike.
local KEY = "LockMute.saved"

-- Ask the system rather than keeping a flag, which would drift on first reload.
-- macOS REMOVES CGSSessionScreenIsLocked when unlocked instead of setting it
-- false, hence the truthy check.
local function isLocked()
    local props = hs.caffeinate.sessionProperties()
    return (props ~= nil and props.CGSSessionScreenIsLocked) and true or false
end

-- The output device may have changed while locked (headphones unplugged, HDMI).
local function targetDevice(uid)
    if uid then
        local device = hs.audiodevice.findDeviceByUID(uid)
        if device then
            return device
        end
    end
    return hs.audiodevice.defaultOutputDevice()
end

--- LockMute:quiet()
--- Method
--- Remember the current audio state, then mute. No-op if already saved.
function obj:quiet()
    -- Several events lead to one quieting (sleep, then lock seconds later). The
    -- second must NOT overwrite the save, or the remembered state becomes
    -- muted=true and unlock never restores sound.
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

    -- HDMI/DisplayPort outputs often have no mute channel and setMuted() does
    -- nothing silently -- only reading it back tells you. Volume 0 is the
    -- fallback; the old volume is already saved.
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
--- Restore the remembered audio state. No-op if there is nothing saved.
function obj:restore()
    local saved = hs.settings.get(KEY)
    if not saved then
        return self
    end

    -- Clear the save BEFORE touching the device, so a failure below still lets
    -- the next lock record real state instead of sticking on a stale save.
    hs.settings.clear(KEY)

    local device = targetDevice(saved.uid)
    if not device then
        log.w("không tìm thấy output device để trả âm")
        return self
    end

    -- Volume first, unmute last: the other order plays sound at an intermediate
    -- volume.
    if saved.volume then
        device:setOutputVolume(saved.volume)
    end
    device:setMuted(saved.muted == true)

    log.f("trả âm: %s (muted=%s volume=%s)", device:uid(), saved.muted, saved.volume)
    return self
end

local w = hs.caffeinate.watcher

-- Four independent routes into "nobody is here", none of which covers the
-- others: idle sleeps or starts the screensaver before locking (the grace period
-- can be minutes), while a manual lock fires without the screen sleeping.
-- quiet() handles the overlap.
local QUIET = {
    [w.screensDidLock] = true,
    [w.screensDidSleep] = true,
    [w.screensaverDidStart] = true,
    [w.systemWillSleep] = true,
}

-- The reverse needs care: a woken screen does NOT mean you are back -- a nudged
-- mouse or a background wake leaves the login screen up. Only screensDidUnlock
-- restores unconditionally; the wake events must check the lock first.
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
    -- Keep the watcher on obj: an unreferenced watcher is garbage-collected and
    -- stops silently.
    obj.watcher = w.new(onEvent):start()

    -- If Hammerspoon was reloaded or killed while locked, nobody heard the
    -- unlock and the save is still there. Recover on startup.
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
