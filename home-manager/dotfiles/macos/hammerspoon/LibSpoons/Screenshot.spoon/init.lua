--- === Screenshot ===
---
--- Chụp vùng chọn, copy vào clipboard, và đẩy sang các máy khác qua scp.
---
--- Trên máy remote, dán vào Claude Code bằng cách gõ: @/tmp/ss.png
--- (dùng cmd+shift+4 thay cho phím này khi cần dán vào app không nhận ảnh, ví dụ Claude CLI.)
---
--- Tách từ Tab.spoon.
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
--- Các máy sẽ nhận ảnh. Máy đang chạy tự bị loại khỏi danh sách.
obj.hosts = { "macmini"}

--- Screenshot.latest
--- Variable
--- Symlink luôn trỏ về ảnh mới nhất, để đường dẫn @/tmp/ss.png dùng được như một hằng số.
obj.latest = "/tmp/ss.png"

--- Screenshot.keep
--- Variable
--- Số ảnh giữ lại trong /tmp. Mỗi lần chụp là một tên mới nên không dọn thì phình mãi.
obj.keep = 20

-- Tên chứa timestamp cố định độ dài nên sort chuỗi = sort thời gian.
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

-- Đẩy ảnh sang các máy khác.
--
-- Dùng hs.task chứ KHÔNG dùng hs.execute. hs.execute là io.popen + f:read("*a"), tức là chờ
-- EOF trên pipe — kể cả khi lệnh có dấu `&`, vì tiến trình nền thừa kế đầu ghi của pipe nên
-- EOF chỉ đến khi nó chết hẳn. ssh không đặt ConnectTimeout, nên một host không với tới được
-- (airm3 mang ra khỏi mạng nhà) treo cả Lua thread của Hammerspoon tới hết TCP timeout, ~75 s
-- mỗi host, tuần tự. Trong lúc đó mọi hotkey — kể cả phím reload để thoát ra — đều chết.
local function push(path)
    local me = (hs.host.localizedName() or ""):lower()
    for _, host in ipairs(obj.hosts) do
        if host ~= me then -- không scp lên chính máy đang ngồi
            hs.task.new("/usr/bin/scp", function(exitCode, _stdout, stderr)
                if exitCode ~= 0 then
                    local msg = (stderr or ""):gsub("%s+$", "")
                    if msg == "" then
                        msg = "exit code " .. tostring(exitCode)
                    end
                    hs.alert.show("scp " .. host .. ": " .. msg, 3)
                end
                -- BatchMode: không bao giờ dừng lại hỏi mật khẩu/passphrase.
                -- ConnectTimeout: bỏ cuộc sau 5 s thay vì chờ hết TCP timeout.
            end, { "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", path, host .. ":" .. obj.latest }):start()
        end
    end
end

--- Screenshot:capture()
--- Method
--- Chụp vùng chọn tương tác, rồi copy + đẩy đi nếu user không huỷ.
function obj:capture()
    -- Đường dẫn duy nhất mỗi lần chụp. Nếu ghi đè một tên cố định thì khi user bấm Esc huỷ
    -- vùng chọn, screencapture không ghi gì, mà hs.fs.attributes() vẫn thấy ảnh của lần TRƯỚC
    -- còn nằm đó — rồi đem ảnh cũ đó vào clipboard và scp sang các máy khác.
    local path = "/tmp/ss-" .. os.date("%Y%m%d-%H%M%S") .. ".png"

    hs.task.new("/usr/sbin/screencapture", function()
        -- Không xét exit code: screencapture vẫn thoát 0 khi user huỷ. Bằng chứng duy nhất
        -- đáng tin là file có xuất hiện ở đường dẫn mới hay không.
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
