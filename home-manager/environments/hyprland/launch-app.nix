# Sinh binding launcher cho hyprland tu configs/shortcuts/apps.shared.toml.
# DOC LUC EVAL — sua file do la phai switch + Tab+r (hyprctl reload).
# Chi la `exec beckon "<app>"` tran, khong workspace logic — hanh vi workspace
# la viec rieng cua hypr.d. File sinh ra o ~/.config/hypr-nix/ vi ~/.config/hypr
# la symlink ca thu muc (xem default.nix).
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

  apps = builtins.attrValues data;

  # Ten app duoc nhung NGUYEN VAN vao mot chuoi shell trong nhay kep, roi ca
  # cum do vao mot chuoi long-bracket cua Lua. Hai ky tu duoi day se lam vo mot
  # trong hai lop do va khong co gi bao — chan ngay tai eval thay vi de config
  # im lang hong.
  badApps = lib.filter (a: lib.hasInfix "]]" a || lib.hasInfix ''"'' a) apps;

  modMap = {
    ctrl = "CTRL";
    super = "SUPER";
    alt = "ALT";
    shift = "SHIFT";
  };

  # "ctrl+super+alt+b" -> "CTRL + SUPER + ALT + b". Modifier la moi token truoc
  # token cuoi; token cuoi giu nguyen (hl.bind nhan keysym: b, space, ...).
  # `hl.bind` tach chuoi phim bang DAU CONG, khong phai dau cach nhu hyprlang.
  toBind = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = map (m: modMap.${m}) (lib.sublist 0 (n - 1) parts);
    key = builtins.elemAt parts (n - 1);
  in
    lib.concatStringsSep " + " (mods ++ [key]);

  lines =
    map (combo: ''hl.bind("${toBind combo}", hl.dsp.exec_cmd([[beckon "${data.${combo}}"]]))'')
    (builtins.attrNames data);
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua `]]` hoac `"`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  '';
    ''
      -- SINH TU configs/shortcuts/apps.shared.toml — dung sua tay file nay.
    ''
    + lib.concatStringsSep "\n" lines
    + "\n"
