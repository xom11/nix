local base = ... -- Tự động lấy tên module (vd: "core" hoặc "extras")
local path = debug.getinfo(1).source:sub(2):match("(.*[/\\])") -- Lấy đường dẫn folder hiện tại

for _, file in ipairs(vim.fn.globpath(path, "*.lua", 0, 1)) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    if name ~= "init" then
        local ok, err = pcall(require, base .. "." .. name)
        if not ok then
            vim.notify("Error loading " .. base .. "." .. name .. "\n" .. err, vim.log.levels.ERROR)
        end
    end
end
