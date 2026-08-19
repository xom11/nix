# Sinh binding launcher cho hyprland tu configs/shortcuts/apps.shared.toml.
# DOC LUC EVAL — sua file do la phai switch + Tab+r (hyprctl reload).
# Chi la `exec beckon "<app>"` tran, khong workspace logic — hanh vi workspace
# la viec rieng cua hypr.d. File sinh ra o ~/.config/hypr-nix/ vi ~/.config/hypr
# la symlink ca thu muc (xem default.nix).
#
# Tra ve CA HAI dinh dang:
#   lua  — cho hyprland.lua (`require`), la duong dang chay
#   conf — cho hyprland.conf (`source`), giu lai lam DUONG LUI cua dot chuyen
#          sang Lua. Hyprland uu tien hyprland.lua va chi lui ve .conf khi
#          khong thay, nen doi ten hyprland.lua la ca cay .conf song lai — bao
#          gom ca file nay. Xoa nua `conf` chi khi da xoa het .conf.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

  apps = builtins.attrValues data;

  # Ten app duoc nhung NGUYEN VAN vao mot chuoi shell trong nhay kep, va (o ban
  # Lua) vao mot chuoi long-bracket. Hai ky tu duoi day se lam vo mot trong hai
  # lop do va khong co gi bao — chan ngay tai eval thay vi de config im lang hong.
  badApps = lib.filter (a: lib.hasInfix "]]" a || lib.hasInfix ''"'' a) apps;

  modMap = {
    ctrl = "CTRL";
    super = "SUPER";
    alt = "ALT";
    shift = "SHIFT";
  };

  # "ctrl+super+alt+b" -> mods = ["CTRL" "SUPER" "ALT"], key = "b".
  # Modifier la moi token truoc token cuoi; token cuoi giu nguyen (ca hai ban
  # deu nhan keysym: b, space, ...).
  split = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
  in {
    mods = map (m: modMap.${m}) (lib.sublist 0 (n - 1) parts);
    key = builtins.elemAt parts (n - 1);
  };

  # hyprlang: modifier noi bang DAU CACH, roi dau phay truoc phim.
  toBindConf = combo: let
    p = split combo;
  in
    lib.concatStringsSep " " p.mods + ", " + p.key;

  # hl.bind: MOT chuoi duy nhat, moi thanh phan noi bang ` + `.
  toBindLua = combo: let
    p = split combo;
  in
    lib.concatStringsSep " + " (p.mods ++ [p.key]);

  combos = builtins.attrNames data;

  confLines = map (combo: ''bind = ${toBindConf combo}, exec, beckon "${data.${combo}}"'') combos;

  luaLines = map (combo: ''hl.bind("${toBindLua combo}", hl.dsp.exec_cmd([[beckon "${data.${combo}}"]]))'') combos;

  confHeader = ''
    # vim: ft=hyprlang
    # SINH TU configs/shortcuts/apps.shared.toml — dung sua tay file nay.
  '';

  luaHeader = ''
    -- SINH TU configs/shortcuts/apps.shared.toml — dung sua tay file nay.
  '';
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua `]]` hoac `"`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  ''; {
    conf = confHeader + lib.concatStringsSep "\n" confLines + "\n";
    lua = luaHeader + lib.concatStringsSep "\n" luaLines + "\n";
  }
