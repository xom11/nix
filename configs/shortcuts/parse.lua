-- Parser cho apps.toml, cong hai che do dong lenh (--dump, --readme).
--
-- Lua THUAN: khong duoc dung hs.* o day. Hammerspoon khong chay duoc tren CI,
-- `lua` tran thi co trong nixpkgs -- tach ra thi moi test duoc.
--
-- Chi hieu dung subset TOML ma apps.toml duoc phep dung:
--   dong trong | dong bat dau bang # | [[app]] | [[shift]] | khoa = "gia tri"
-- Gap thu khac thi BAO LOI VA DUNG, khong bo qua. Bo qua am tham tao ra dung
-- kich ban "Nix doc du 20 app, Lua doc duoc 19", va no chi lo ra khi bam phim
-- thu 20 vao thang sau.

local M = {}

M.TARGETS = { "gnome", "macos", "sway", "windows" }
M.LAYERS = { "app", "shift" }

local FIELD = {
  key = true, id = true,
  gnome = true, macos = true, sway = true, windows = true,
}

local IS_TARGET = {}
for _, t in ipairs(M.TARGETS) do IS_TARGET[t] = true end

--- @return table|nil layers, string|nil err
function M.parse(text)
  local layers = { app = {}, shift = {} }
  local entry, lineNo = nil, 0

  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    lineNo = lineNo + 1
    local s = line:match("^%s*(.-)%s*$")

    if s == "" or s:sub(1, 1) == "#" then
      -- bo qua
    elseif s == "[[app]]" or s == "[[shift]]" then
      entry = {}
      table.insert(layers[s:sub(3, -3)], entry)
    else
      local k, v = s:match('^([a-z_]+)%s*=%s*"([^"]*)"$')
      if not k then
        return nil, ("dong %d: ngoai subset TOML cho phep: %s"):format(lineNo, line)
      elseif not entry then
        return nil, ("dong %d: `%s` nam ngoai moi [[app]]/[[shift]]"):format(lineNo, k)
      elseif not FIELD[k] then
        return nil, ("dong %d: khoa la `%s`"):format(lineNo, k)
      elseif entry[k] ~= nil then
        return nil, ("dong %d: `%s` lap trong cung mot bang"):format(lineNo, k)
      end
      entry[k] = v
    end
  end

  for _, layer in ipairs(M.LAYERS) do
    local seen = {}
    for _, e in ipairs(layers[layer]) do
      if not e.key then
        return nil, ("[[%s]]: thieu `key`"):format(layer)
      elseif not e.id then
        return nil, ("[[%s]] key=%s: thieu `id`"):format(layer, e.key)
      elseif seen[e.key] then
        return nil, ("[[%s]]: phim `%s` bi bind hai lan"):format(layer, e.key)
      end
      seen[e.key] = true
    end
  end

  return layers
end

function M.idFor(entry, target)
  local v = entry[target]
  if v == nil then return entry.id end
  return v
end

function M.bindings(layers, layer, target)
  local out = {}
  for _, e in ipairs(layers[layer]) do
    local id = M.idFor(e, target)
    if id ~= "" then table.insert(out, { key = e.key, id = id }) end
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

--- Sap xep CA DONG hoan chinh, khong sap theo tung cot. Nix (builtins.sort) va
--- AHK (StrCompare ordinal) lam y het, nen ba ban chac chan ra cung thu tu.
function M.dump(layers, target)
  local lines = {}
  for _, layer in ipairs(M.LAYERS) do
    for _, b in ipairs(M.bindings(layers, layer, target)) do
      table.insert(lines, table.concat({ target, layer, b.key, b.id }, "\t"))
    end
  end
  table.sort(lines)
  return table.concat(lines, "\n")
end

function M.readme(layers)
  local out = {
    "# Phim tat focus-or-launch",
    "",
    "<!-- SINH RA TU apps.toml BOI sync.sh -- DUNG SUA TAY -->",
    "",
    "- `Cap` = `cmd+ctrl+alt` (macOS) / `super+ctrl+alt` (Windows, Linux)",
    "- Engine la `beckon` o ca bon nen tang.",
    "- Cot **Windows** duoi day la trang thai DU DINH, CHUA chay that: `parse.ahk`",
    "  chua ton tai nen `launch-app.ahk` van dung bang phim hardcode rieng cua no.",
    "",
  }
  local title = { app = "## `Cap` + phim", shift = "## `Cap` + `Shift` + phim" }
  local cols = { "macos", "windows", "gnome", "sway" }

  for _, layer in ipairs(M.LAYERS) do
    table.insert(out, title[layer])
    table.insert(out, "")
    table.insert(out, "| Phim | macOS | Windows | GNOME | sway |")
    table.insert(out, "|---|---|---|---|---|")

    local sorted = {}
    for _, e in ipairs(layers[layer]) do table.insert(sorted, e) end
    table.sort(sorted, function(a, b) return a.key < b.key end)

    for _, e in ipairs(sorted) do
      local cells = {}
      for _, t in ipairs(cols) do
        local id = M.idFor(e, t)
        table.insert(cells, id == "" and "--" or id)
      end
      table.insert(out, ("| `%s` | %s |"):format(e.key, table.concat(cells, " | ")))
    end
    table.insert(out, "")
  end

  table.insert(out, "## Cac lop phim khac (khong sinh tu apps.toml)")
  table.insert(out, "")
  table.insert(out, "Hai nhom nay khong di qua apps.toml/beckon nen khong nam trong bang")
  table.insert(out, "tren. Doc truc tiep o nguon thay vi chep lai o day, de tranh bang tay")
  table.insert(out, "bi lech nhu file README cu:")
  table.insert(out, "")
  table.insert(out, "- Lop Tab (`Tab` giu lam modifier): macOS o")
  table.insert(out, "  `home-manager/dotfiles/macos/hammerspoon/MySpoons/Tab.spoon/init.lua`,")
  table.insert(out, "  sway o `home-manager/environments/sway/sway.d/conf.d/tab.conf`, Windows o")
  table.insert(out, "  `home-manager/dotfiles/windows/ahk/tab-key.ahk`.")
  table.insert(out, "- Phim quan ly nguon (khoa man/ngu/tat may/khoi dong lai/dang xuat):")
  table.insert(out, "  macOS o")
  table.insert(out, "  `home-manager/dotfiles/macos/hammerspoon/MySpoons/PowerManager.spoon/init.lua`,")
  table.insert(out, "  sway o `home-manager/environments/sway/sway.d/conf.d/system.conf` (muc")
  table.insert(out, "  \"Power Keybindings\"), Windows o")
  table.insert(out, "  `home-manager/dotfiles/windows/ahk/power-manager.ahk`, GNOME dung")
  table.insert(out, "  keybinding co san cua desktop, khai o")
  table.insert(out, "  `home-manager/environments/gnome/shortcuts.nix`.")
  table.insert(out, "")

  return table.concat(out, "\n")
end

-- Che do dong lenh. Chi chay khi file NAY la script duoc goi, khong chay khi
-- Hammerspoon dofile() no.
if arg and arg[0] and arg[0]:match("parse%.lua$") then
  local dir = arg[0]:match("^(.*)/[^/]+$") or "."
  local f = io.open(dir .. "/apps.toml", "r")
  if not f then
    io.stderr:write("khong mo duoc " .. dir .. "/apps.toml\n")
    os.exit(1)
  end
  local text = f:read("*a")
  f:close()

  local layers, err = M.parse(text)
  if not layers then
    io.stderr:write("apps.toml: " .. err .. "\n")
    os.exit(1)
  end

  if arg[1] == "--dump" and IS_TARGET[arg[2] or ""] then
    local d = M.dump(layers, arg[2])
    if d ~= "" then print(d) end
  elseif arg[1] == "--readme" then
    print(M.readme(layers))
  else
    io.stderr:write("dung: parse.lua --dump <gnome|macos|sway|windows> | --readme\n")
    os.exit(2)
  end
end

return M
