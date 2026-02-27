local obj = {}
obj.__index = obj

local function enableGonhanh()
    hs.execute("open -g -a GoNhanh")
end

local function disableGonhanh()
    hs.execute("killall GoNhanh 2>/dev/null")
end

local function isGonhanhRunning()
    local output = hs.execute("pgrep -x GoNhanh")
    return output ~= ""
end

local function isUnicodeHexInput()
    local sourceID = hs.keycodes.currentSourceID()
    if sourceID then
        return sourceID:find("UnicodeHexInput") ~= nil
    end
    return false
end

local function inputSourceChanged()
    local isTarget = isUnicodeHexInput()
    local isRunning = isGonhanhRunning()

    if isTarget and not isRunning then
        enableGonhanh()
    elseif not isTarget and isRunning then
        disableGonhanh()
    end
end

function obj:init()
    hs.keycodes.inputSourceChanged(inputSourceChanged)

    if isUnicodeHexInput() and not isGonhanhRunning() then
        enableGonhanh()
    end
end

return obj
