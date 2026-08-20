--- === LangSwitch ===
---
--- Jump straight to one input mode, one key per language -- not the cycling the
--- macOS default key does. Split out of Tab.spoon.
---
--- Switching is delegated to `tongue` because a "mode" is TWO levers -- the
--- system layout and the Vietnamese IME -- and hs.keycodes only reaches the
--- first. `tongue` moves both and reads the machine back before reporting
--- success.
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
--- Modes `tongue` understands. The mode -> (layout, IME) map lives in
--- ~/.config/tongue/config.toml, so only one place knows Apple's source IDs.
--- These names are also what LanguageMemory persists.
obj.modes = { "vi", "en", "zh" }

-- A GUI app gets its PATH from launchd, which does not include Nix's profile,
-- and hs.task needs an absolute path. So ask a login shell ONCE and remember --
-- hardcoding fails across machines and changes on every upgrade.
local binary = nil
local waiting = {}

-- A login shell can mix prompt escapes into stdout, so take the LAST token of a
-- line rather than trusting the whole line. Do not use `.*(/[^%s]*/tongue)$`:
-- the greedy `.*` leaves the SHORTEST match, turning a real path into
-- "/bin/tongue" -- nonexistent but plausible enough to pass every shape check.
-- Also stat it: re-probing beats remembering a broken path until the next reload.
local function parseBinary(out)
    for line in (out or ""):gmatch("[^\r\n]+") do
        local token = line:gsub("%c", ""):match("([^%s]+)%s*$")
        if token and token:match("/tongue$") and hs.fs.attributes(token, "mode") == "file" then
            return token
        end
    end
    return nil
end

-- /bin/zsh, not $SHELL: a GUI process often has no SHELL. `-l` loads the profile
-- where Nix extends PATH; no `-i`, to skip interactive shell config.
local function withBinary(fn)
    if binary then
        return fn(binary)
    end
    table.insert(waiting, fn)
    if #waiting > 1 then
        return -- a probe is already running; queue up
    end
    hs.task.new("/bin/zsh", function(_, out)
        binary = parseBinary(out)
        local work = waiting
        waiting = {}
        if not binary then
            hs.alert.show("LangSwitch: không tìm thấy `tongue` trong PATH", 3)
            log.e("không tìm thấy tongue — đã cài và rebuild chưa?")
            return -- waiting is empty, so the next keypress re-probes
        end
        log.i("tongue: " .. binary)
        for _, f in ipairs(work) do
            f(binary)
        end
    end, { "-lc", "command -v tongue" }):start()
end

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
        -- hs.task.new returns nil for an unrunnable path. Unchecked, `:start()`
        -- throws into the console and the hotkey just does nothing, silently.
        if not task then
            binary = nil -- force a re-probe next time
            hs.alert.show("LangSwitch: không chạy được " .. bin, 3)
            log.e("hs.task.new trả nil cho " .. bin)
            return
        end
        task:start()
    end)
end

--- LangSwitch:switch(mode)
--- Method
--- Switch because the USER asked, then notify listeners. Deliberate actions
--- only -- automatic restores go through :apply().
function obj:switch(mode)
    run(mode, true)
    return self
end

--- LangSwitch:apply(mode)
--- Method
--- Switch WITHOUT notifying listeners -- for automatic restores.
---
--- Separate from :switch() to kill the relearn loop at the root: a restore that
--- signalled would make LanguageMemory relearn what it just set, and since the
--- call takes ~200 ms the focused app may have changed by then, filing the old
--- app's mode under the new one.
function obj:apply(mode)
    run(mode, false)
    return self
end

--- LangSwitch:onModeChange(fn)
--- Method
--- Register a function to run after each successful :switch().
---
--- The ONLY channel that sees a user mode change: with an external IME, `vi` and
--- `en` share one input source (ABC), so macOS fires no event between them.
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
