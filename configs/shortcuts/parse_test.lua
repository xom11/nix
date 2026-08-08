-- Chay: LC_ALL=C lua configs/shortcuts/parse_test.lua
--
-- Khong dung framework: repo nay chua co ha tang test Lua nao, va mot file
-- assert tran thi chay duoc bang `lua` co san trong nixpkgs, khong them input.

local dir = arg[0]:match("^(.*)/[^/]+$") or "."
local P = dofile(dir .. "/parse.lua")

local failures = 0
local function check(name, ok, detail)
  if ok then
    print("ok   " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. (detail and ("  -- " .. detail) or ""))
  end
end

local function parseOk(text)
  local layers, err = P.parse(text)
  assert(layers, "parse that bai ngoai y muon: " .. tostring(err))
  return layers
end

-- 1. Parse co ban
local l = parseOk('[[app]]\nkey = "c"\nid = "Claude"\n')
check("parse co ban", #l.app == 1 and l.app[1].key == "c" and l.app[1].id == "Claude")

-- 2. Override thang id
l = parseOk('[[app]]\nkey = "b"\nid = "Brave"\nmacos = "Brave Browser"\n')
check("override thang id", P.idFor(l.app[1], "macos") == "Brave Browser")
check("khong override thi lay id", P.idFor(l.app[1], "windows") == "Brave")

-- 3. Chuoi rong nghia la khong bind
l = parseOk('[[app]]\nkey = "z"\nid = "Zalo"\nmacos = ""\n')
check("id rong bi loai khoi bindings", #P.bindings(l, "app", "macos") == 0)
check("target khac van co", #P.bindings(l, "app", "windows") == 1)

-- 4. Hai lop deu ap dung cho moi target
l = parseOk('[[app]]\nkey = "c"\nid = "Claude"\n[[shift]]\nkey = "m"\nid = "Gmail"\n')
check("lop shift ap dung cho gnome", #P.bindings(l, "shift", "gnome") == 1)

-- 5. Dump sap xep theo dong hoan chinh, app truoc shift
l = parseOk([=[
[[shift]]
key = "m"
id = "Gmail"
[[app]]
key = "space"
id = "kitty"
[[app]]
key = "c"
id = "Claude"
]=])
check("dump sap xep dung",
  P.dump(l, "macos") == "macos\tapp\tc\tClaude\nmacos\tapp\tspace\tkitty\nmacos\tshift\tm\tGmail",
  P.dump(l, "macos"))

-- 6. Cac loi phai lam parse dung han
local function parseFails(name, text, wanted)
  local layers, err = P.parse(text)
  check(name, layers == nil and err and err:find(wanted, 1, true) ~= nil, tostring(err))
end

parseFails("comment cuoi dong bi tu choi",
  '[[app]]\nkey = "c"  # ghi chu\n', "ngoai subset")
parseFails("nhay don bi tu choi",
  "[[app]]\nkey = 'c'\n", "ngoai subset")
parseFails("khoa la bi tu choi",
  '[[app]]\nkey = "c"\nlinux = "x"\n', "khoa la")
parseFails("khoa lap trong mot bang bi tu choi",
  '[[app]]\nkey = "c"\nkey = "d"\n', "lap trong")
parseFails("gan ngoai moi bang bi tu choi",
  'key = "c"\n', "nam ngoai")
parseFails("thieu id bi tu choi",
  '[[app]]\nkey = "c"\n', "thieu")
parseFails("thieu key bi tu choi",
  '[[app]]\nid = "Claude"\n', "thieu")
parseFails("trung phim trong mot lop bi tu choi",
  '[[app]]\nkey = "c"\nid = "A"\n[[app]]\nkey = "c"\nid = "B"\n', "hai lan")

-- 7. Trung phim GIUA hai lop thi hop le
l = parseOk('[[app]]\nkey = "b"\nid = "Brave"\n[[shift]]\nkey = "b"\nid = "Brave"\n')
check("trung phim giua hai lop la hop le", #l.app == 1 and #l.shift == 1)

-- 8. Readme generation voi override va empty id
l = parseOk([=[
[[app]]
key = "c"
id = "Claude"
macos = ""
[[app]]
key = "b"
id = "Brave"
[[shift]]
key = "m"
id = "Gmail"
gnome = ""
]=])
local readme = P.readme(l)
check("readme co tieu de lop app", readme:find("## `Cap` + phim", 1, true) ~= nil)
check("readme co tieu de lop shift", readme:find("## `Cap` + `Shift` + phim", 1, true) ~= nil)
check("readme render id rong thanh --", readme:find("| `c` | -- |", 1, true) ~= nil)
check("readme co bon cot target dung thu tu", readme:find("| macOS | Windows | GNOME | sway |", 1, true) ~= nil)

print(failures == 0 and "\nTAT CA PASS" or ("\n" .. failures .. " FAIL"))
os.exit(failures == 0 and 0 or 1)
