local modname = ... or "extras" -- Lấy tên module truyền vào, nếu không có thì mặc định là "extras"
local prefix = modname:match("(.-)%.?init$") or modname
prefix = prefix .. "." -- Thêm dấu chấm để nối module con (vd: "extras.")

local dir = vim.fn.stdpath("config") .. "/lua/" .. prefix:gsub("%.", "/")

if vim.fn.isdirectory(dir) == 1 then
  for name, type in vim.fs.dir(dir) do
    if type == "file" and name:match("%.lua$") and name ~= "init.lua" then
      require(prefix .. name:sub(1, -5))
    end
  end
end
