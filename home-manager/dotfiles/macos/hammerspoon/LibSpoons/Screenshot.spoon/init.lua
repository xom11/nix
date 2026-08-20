--- === Screenshot ===
---
--- Capture a region, copy it, and scp it to the other machines.
---
--- On a remote machine, paste into Claude Code by typing: @/tmp/ss.png
--- Split out of Tab.spoon.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("Screenshot")
--- spoon.Screenshot.hosts = { "macmini", "rog" }
--- spoon.Screenshot:bindHotkeys({ capture = { tab, "s" } })
--- ```

local obj = {}
obj.__index = obj

obj.name = "Screenshot"
obj.version = "1.0"
obj.author = "kln"
obj.license = "MIT"

--- Screenshot.hosts
--- Variable
--- Machines that receive the image. The local one drops itself.
obj.hosts = { "macmini"}

--- Screenshot.latest
--- Variable
--- Symlink to the newest capture, so the path works as a constant.
obj.latest = "/tmp/ss.png"

--- Screenshot.keep
--- Variable
--- How many to keep: each capture gets a new name, so this grows without pruning.
obj.keep = 20

-- Fixed-width timestamps, so a string sort is a time sort.
local function prune()
    local files = {}
    local ok = pcall(function()
        for f in hs.fs.dir("/tmp") do
            if f:match("^ss%-%d+%-%d+%.png$") then
                files[#files + 1] = f
            end
        end
    end)
    if not ok then
        return
    end
    table.sort(files)
    for i = 1, #files - obj.keep do
        os.remove("/tmp/" .. files[i])
    end
end

-- hs.task, NOT hs.execute: the latter is io.popen + read("*a"), which waits for EOF on the
-- pipe even with a trailing `&`, because the background process inherits the write end. An
-- unreachable host then freezes Hammerspoon's Lua thread for the full TCP timeout (~75 s
-- each, sequentially), killing every hotkey including the reload key.
local function push(path)
    local me = (hs.host.localizedName() or ""):lower()
    for _, host in ipairs(obj.hosts) do
        if host ~= me then -- never scp to the machine we are sitting at
            hs.task.new("/usr/bin/scp", function(exitCode, _stdout, stderr)
                if exitCode ~= 0 then
                    local msg = (stderr or ""):gsub("%s+$", "")
                    if msg == "" then
                        msg = "exit code " .. tostring(exitCode)
                    end
                    hs.alert.show("scp " .. host .. ": " .. msg, 3)
                end
                -- BatchMode never stops to ask for a passphrase; ConnectTimeout gives up
                -- after 5 s instead of waiting out the TCP timeout.
            end, { "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", path, host .. ":" .. obj.latest }):start()
        end
    end
end

--- Screenshot:capture()
--- Method
--- Interactive region capture, then copy and push unless cancelled.
function obj:capture()
    -- A fresh path per capture. With a fixed name, cancelling writes nothing but the
    -- PREVIOUS image is still there -- and would be copied and pushed as if it were new.
    local path = "/tmp/ss-" .. os.date("%Y%m%d-%H%M%S") .. ".png"

    hs.task.new("/usr/sbin/screencapture", function()
        -- screencapture exits 0 even when cancelled, so the only reliable evidence is
        -- whether the file appeared.
        if not hs.fs.attributes(path) then
            return
        end

        local img = hs.image.imageFromPath(path)
        if img then
            hs.pasteboard.writeObjects(img)
        end

        os.remove(obj.latest)
        hs.fs.link(path, obj.latest, true)

        push(path)
        prune()
    end, { "-i", path }):start()

    return self
end

function obj:bindHotkeys(mapping)
    hs.spoons.bindHotkeysToSpec({
        capture = function()
            obj:capture()
        end,
    }, mapping)
    return self
end

return obj
