# Ý tưởng mở rộng Hammerspoon

Sinh ra từ đợt audit 2026-07-28/29 (4 lăng kính audit + phản biện đối kháng, 53 agent).
Đây là **danh sách chờ**, không phải kế hoạch — chưa cái nào được cam kết làm.

Phác code trong file này là gợi ý ban đầu của đợt audit, **chưa chạy thử**. Vài chỗ tham
chiếu tới code đã bị đổi kể từ đó; những chỗ đó có ghi chú `[LỖI THỜI]`.

Mức công: `nhỏ` = một buổi tối, `vừa` = một spoon mới, `lớn` = cần dò API trước.

---

## Đã làm

| Ý tưởng | Kết quả |
|---|---|
| Screenshot v2 — async, timestamp, host-aware, báo scp | `fa50f4a4`, nay ở `LibSpoons/Screenshot.spoon` |
| `caffeinate.watcher` khôi phục input source sau wake/unlock | `a5dcebee`, trong `LanguageMemory.spoon` |
| `screen.watcher` đặt lại vị trí chấm caffeine | `65967232`, trong `LibSpoons/Caffeine.spoon` |

Phần lưu/khôi phục **layout** theo chữ ký màn hình thì chưa — xem ý tưởng 4 bên dưới.

---

## Ngôn ngữ

### 1. Chỉ báo input source VI/EN/ZH trên menubar `[nhỏ]`

Menubar hiện nhãn theo quy ước của repo này thay vì tên Apple đặt, kèm flash HUD giữa màn
hình ~0,4 s để thấy được cả khi app fullscreen che menubar. Mở rộng: click để đổi nhanh,
click phải để xem/xoá memory của app đang focus.

**Vì sao đáng làm nhất trong danh sách:** quy ước `ABC = tiếng Việt` /
`Unicode Hex Input = tiếng Anh` khiến menubar gốc của macOS **hiển thị ngược nghĩa hoàn
toàn** — đang gõ tiếng Việt thì macOS ghi "ABC". Cộng thêm `LanguageMemory` tự đổi nguồn sau
lưng mỗi lần focus app, nên không nhìn vào đâu biết đang ở chế độ nào.

```lua
local labels = { ABC = "VI", UnicodeHexInput = "EN", Pinyin = "ZH" }
local function labelOf(sid)
  for k, v in pairs(labels) do
    if sid and sid:find(k, 1, true) then return v end
  end
  return "??"
end

local mb = hs.menubar.new()
function obj.refresh()
  local l = labelOf(hs.keycodes.currentSourceID())
  mb:setTitle(l)
  hs.alert.closeAll()
  hs.alert.show(l, { textSize = 40 }, 0.4)
end
```

**Bắt buộc kèm theo:** `hs.keycodes.inputSourceChanged` chỉ có **một slot toàn cục** — nó gọi
`keycodes._callback:_stop()` rồi thay bằng callback mới. `LanguageMemory` đang giữ slot đó.
Muốn spoon này cũng nghe thì phải gom về **một dispatcher chung**, không được đăng ký thêm.

### 2. Ép tiếng Anh khi con trỏ vào ô mật khẩu `[lớn]`

`hs.axuielement.observer` nghe `AXFocusedUIElementChanged`; gặp subrole `AXSecureTextField`
thì tạm chuyển sang Unicode Hex Input, rời ô thì trả lại nguồn trước đó.

**Vì sao:** nỗi đau kinh điển của người gõ tiếng Việt — bộ gõ đang bật, click vào ô password
rồi gõ, ký tự bị telex nuốt mà không nhìn thấy được vì ô bị che sao. `LanguageMemory` chỉ có
độ phân giải ở mức **app**, không xuống được mức ô nhập liệu.

```lua
local prev
local function onFocusChange(obs, el)
  local ok, sub = pcall(function() return el:attributeValue("AXSubrole") end)
  if ok and sub == "AXSecureTextField" then
    prev = hs.keycodes.currentSourceID()
    hs.keycodes.currentSourceID("com.apple.keylayout.UnicodeHexInput")
  elseif prev then
    hs.keycodes.currentSourceID(prev)
    prev = nil
  end
end
-- observer gắn theo pid → phải tạo lại mỗi lần app frontmost đổi
```

> ⚠️ **CẦN XÁC MINH trước khi bắt tay:** tên chính xác của API observer
> (`hs.axuielement.observer.new(pid)`, `:addWatcher`, `:callback`, `:start`), và liệu PWA
> Chromium/Electron có báo cáo subrole `AXSecureTextField` hay không. Nếu không thì ý tưởng
> này chết với đúng nhóm app dùng nhiều nhất.

---

## Quản lý cửa sổ

`aerospace` đã gỡ khỏi repo 10/08/2026 (xem `ATTIC.md`), nên `WindowManager.spoon`
(nửa trái / nửa phải / maximize) hiện là toàn bộ window management.

### 3. Modal `hyper+w` — thirds, quarters, center, đẩy sang màn khác `[vừa]`

`h/l` nửa trái/phải (giữ hành vi cũ), `y/o/u/i` bốn góc, `f` maximize, `c` center 70%,
`n` đẩy sang màn hình kế tiếp, `1/2/3` chia ba cho màn rộng, Esc thoát. `hyper+w` đang trống.

```lua
local m = hs.hotkey.modal.new(hyper, "w")
local function place(fx, fy, fw, fh)
  local win = hs.window.focusedWindow()
  if not win then return end
  local s = win:screen():frame()
  win:setFrame({ x = s.x + s.w * fx, y = s.y + s.h * fy, w = s.w * fw, h = s.h * fh })
  m:exit()
end
m:bind({}, "h", function() place(0, 0, .5, 1) end)
m:bind({}, "y", function() place(0, 0, .5, .5) end)
m:bind({}, "c", function() place(.15, .15, .7, .7) end)
```

Nhớ bind Escape để thoát modal — bài học từ modal `tab+d`.

### 4. Tự bố trí cửa sổ khi cắm/rút màn hình `[vừa]`

`hs.screen.watcher` phát hiện đổi cấu hình → `hs.layout.apply` một layout đặt sẵn, và
lưu/khôi phục theo **chữ ký màn hình** (danh sách UUID đã sắp xếp).

```lua
local sig = {}
for _, s in ipairs(hs.screen.allScreens()) do sig[#sig + 1] = s:getUUID() end
table.sort(sig)
applyLayout(table.concat(sig, ","))
```

> ⚠️ Watcher bắn **nhiều lần liên tiếp** khi cắm dock (mỗi màn hình xuất hiện một lần) — phải
> debounce, nếu không layout chạy giữa chừng. `hs.layout.apply` khớp app theo tên, mà PWA
> Chromium đều cùng tên tiến trình.
>
> Nên kèm reset `originalFrames` trong `WindowManager` khi cấu hình màn hình đổi.

### 5. Window chooser `tab+space` `[vừa]`

`hs.chooser` liệt kê mọi cửa sổ (app + title + tên màn hình), fuzzy search, Enter để focus,
sắp theo MRU. `tab+space` đang trống hoàn toàn.

**Vì sao:** `cmd+tab` chỉ chuyển app, `cmd+\`` chỉ vòng trong app và hỏng với PWA — mà setup
này mở rất nhiều PWA cùng engine (Claude, Gemini, Google Keep, Messenger, Youtube, DeepSeek).

```lua
local chooser = hs.chooser.new(function(c)
  if c and c.id then
    local w = hs.window.get(c.id)
    if w then w:focus() end
  end
end)
hs.hotkey.bind(tab, "space", function()
  local rows = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() then
      rows[#rows + 1] = {
        text = w:application():name(),
        subText = (w:title() or "") .. " — " .. w:screen():name(),
        id = w:id(),
      }
    end
  end
  chooser:choices(rows)
  chooser:show()
end)
```

### 6. `hs.spaces` — chuyển/ném cửa sổ giữa Spaces `[vừa]`

`hyper+1..5` nhảy Space, `tab+shift+1..5` ném cửa sổ đang focus sang rồi nhảy theo.

> ⚠️ **Module dễ vỡ nhất danh sách.** `hs.spaces` dựa trên private API của macOS, hành vi đổi
> theo phiên bản và có thể cần tắt "Displays have separate Spaces". Xác minh module có mặt và
> chạy được trên bản macOS hiện tại trước khi đầu tư.

---

## Nhiều máy

### 7. Cầu thông báo `hammerspoon://` cho Claude Code hook `[nhỏ]`

Task xong → notify, click để nhảy về đúng cửa sổ kitty. Từ máy khác:
`ssh macmini 'hs -c "notify(...)"'` khi `nixos-rebuild` xong.

**Vì sao:** `hs.ipc.cliInstall()` đã bật ở `init.lua` nhưng **không file nào trong repo dùng**
— một cổng điều khiển mở sẵn bỏ trống. Mô hình làm việc là giao task rồi chuyển cửa sổ khác,
hiện không có gì báo khi agent xong hay khi nó dừng hỏi permission.

```lua
hs.urlevent.bind("notify", function(_, params)
  hs.notify.new(function()
    if params.win then jump(params.win) end  -- dùng lại hàm jump ở ý tưởng 8
  end, {
    title = params.title or "Claude Code",
    informativeText = params.msg or "",
    withdrawAfter = 0,
  }):send()
end)
-- Claude Code hook: open "hammerspoon://notify?title=rog&msg=done&win=rog"
```

Rủi ro mà đợt audit nêu (`/usr/local/bin` không ghi được) **đã hết**: `cliStatus()` nay trả
`true` sau commit `15bda637`.

### 8. Session jumper `hyper+x` `[vừa]`

Hồi sinh `LaunchTerminal.spoon` (đang bị comment) nhưng bỏ `hs.execute(cmd, true)` — chính cờ
thứ hai đó nạp `~/.zshrc` trước mỗi lời gọi và làm nó chậm tới mức bị tắt.

**Vì sao:** beckon giải quyết ở tầng **app** (focus/cycle trong kitty), không giải quyết được
"đưa tôi tới đúng cửa sổ ssh rog". Hiện muốn tới session rog phải `hyper+space` vào kitty rồi
cycle qua N cửa sổ.

```lua
local function jump(title, host)
  local app = hs.application.get("kitty")
  for _, win in ipairs(app and app:allWindows() or {}) do
    if win:title():find(title, 1, true) then
      if win:id() == (hs.window.focusedWindow() or {}).id then
        win:application():hide()
      else
        win:focus()
      end
      return
    end
  end
  hs.task.new("/usr/bin/open", nil,
    { "-na", "kitty", "--args", "--title", title, "--", "ssh", host }):start()
end
```

### 9. Clipboard history `[vừa]`

Ring buffer 50–200 mục, `hs.chooser` fuzzy search, chọn xong set contents rồi bắn `cmd+v`.
Thêm mục hành động "gửi sang rog/macmini" → `ssh <host> pbcopy` (macOS) hoặc
`xclip -selection clipboard` (Linux).

**Vì sao:** nhu cầu "đưa nội dung sang máy kia" đã tồn tại và đang được giải quyết **nửa vời,
chỉ cho ảnh** bằng scp trong `Screenshot.spoon`. Dev sống trong kitty/tmux/ssh nhiều máy copy
path, hash commit, drv path Nix liên tục.

```lua
local hist, MAX = {}, 200
pbWatcher = hs.pasteboard.watcher.new(function(s)
  if not s or s == "" or hist[1] == s then return end
  table.insert(hist, 1, s)
  while #hist > MAX do table.remove(hist) end
end)
```

> Lọc bỏ nội dung đến từ password manager. Nếu dùng cách poll `changeCount()` mỗi 0,5 s thay
> cho `pasteboard.watcher` thì nhớ đó là một timer chạy mãi.

### 10. `hs.usb.watcher` — kickstart kanata khi cắm bàn phím `[nhỏ]`

**Vì sao:** toàn bộ hệ phím tắt do kanata sinh ra (Tab-giữ = `cmd+ctrl+shift`,
Caps-giữ = `cmd+ctrl+alt`). Kanata không grab được bàn phím vừa cắm là **mọi hotkey chết cùng
lúc**.

```lua
usbWatcher = hs.usb.watcher.new(function(e)
  if e.eventType ~= "added" then return end
  if not (e.productName or ""):match("[Kk]eyboard") then return end
  hs.timer.doAfter(2, function()
    hs.task.new("/bin/launchctl", nil,
      { "kickstart", "-k", "system/<label-cua-kanata>" }):start()
  end)
end):start()
```

> ⚠️ **Vướng mắc chưa giải:** `launchctl kickstart` trên domain `system/` cần **root**, mà
> Hammerspoon chạy dưới user. Đợt audit tự ghi "nhiều khả năng không chạy được". Cần cách
> khác — ví dụ một launchd agent riêng, hoặc để kanata tự phát hiện thiết bị mới.
> Cũng phải tra label launchd thật trong `nix-darwin/launchd/kanata` trước khi hardcode.

---

## Khác

### 11. URL router theo domain `[vừa]`

`hs.urlevent.setDefaultHandler("http")` rồi điều hướng từng domain sang đúng app:
`youtube.com` → PWA Youtube, `claude.ai` → PWA Claude, `gemini.google.com` → Google Gemini,
`mail.google.com` → Gmail, còn lại → Brave.

**Vì sao:** `LaunchApp.spoon` cho thấy setup này sống bằng PWA — mỗi cái một app riêng có
hotkey riêng. Nhưng bấm link YouTube trong Telegram thì macOS chỉ biết mở browser mặc định.

```lua
local byHost = {
  ["youtube.com"] = "Youtube",
  ["claude.ai"] = "Claude",
  ["gemini.google.com"] = "Google Gemini",
  ["mail.google.com"] = "Gmail",
}
hs.urlevent.httpCallback = function(_, host, _, fullURL)
  local h = (host or ""):gsub("^www%.", "")
  local app = byHost[h]
  -- gọi beckon để focus/mở app, fallback mở browser mặc định
end
```

> `[LỖI THỜI]` Phác gốc hardcode `/etc/profiles/per-user/<user>/bin/beckon`. Từ commit
> `ec8c6919`, `LaunchApp.spoon` đã có hàm dò beckon qua nhiều vị trí — dùng lại nó thay vì
> hardcode.
>
> Đặt Hammerspoon làm default handler cho http là thay đổi ở mức hệ thống: nếu Hammerspoon
> không chạy thì link không mở được. Cân nhắc fallback.
