--- === LangSwitch ===
---
--- Đổi thẳng sang một input source cụ thể, mỗi ngôn ngữ một phím — không phải vòng qua lại
--- như phím đổi bộ gõ mặc định của macOS.
---
--- Tách từ Tab.spoon.
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
obj.version = "1.0"
obj.author = "kln"
obj.license = "MIT"

--- LangSwitch.sources
--- Variable
--- Bảng nhãn ngôn ngữ -> sourceID.
---
--- Dùng sourceID chứ không dùng tên hiển thị. "Pinyin – Simplified" và "Unicode Hex Input" là
--- chuỗi đã bản địa hoá, đổi theo ngôn ngữ hệ thống và theo phiên bản macOS; so tên là hỏng
--- lặng lẽ khi Apple đổi chữ. sourceID cũng chính là định danh LanguageMemory ghi vào
--- ~/.hammerspoon/LanguageMemory.json, nên hai chỗ nói cùng một thứ tiếng.
---
--- Ba ID dưới đọc từ chính máy này: đổi sang từng nguồn theo tên rồi hỏi currentSourceID().
--- Quy ước của repo này: ABC = tiếng Việt, Unicode Hex Input = tiếng Anh.
obj.sources = {
    zh = "com.apple.inputmethod.SCIM.ITABC", -- Pinyin – Simplified
    vi = "com.apple.keylayout.ABC", -- ABC
    en = "com.apple.keylayout.UnicodeHexInput", -- Unicode Hex Input
}

--- LangSwitch:switch(id)
--- Method
--- Đổi sang sourceID cho trước, báo alert nếu không đổi được.
---
--- currentSourceID(id) trả true khi đổi được, false khi nguồn chưa được bật trong
--- System Settings — và khi false thì giữ nguyên nguồn đang dùng, không làm hỏng trạng thái.
function obj:switch(id)
    if not id then
        return false
    end
    if not hs.keycodes.currentSourceID(id) then
        hs.alert.show("Không đổi được input source: " .. id, 2)
        return false
    end
    return true
end

function obj:bindHotkeys(mapping)
    local spec = {}
    for label in pairs(obj.sources) do
        spec[label] = function()
            obj:switch(obj.sources[label])
        end
    end
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

return obj
