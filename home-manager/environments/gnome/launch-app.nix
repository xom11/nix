# Bang phim song o configs/shortcuts/apps.toml, dung chung voi macOS, Windows
# va sway. File nay chi con viec doi no thanh dconf custom-keybindings.
#
# Doc luc EVAL, khac han macOS/Windows (doc luc chay): sua apps.toml roi phai
# `home-manager switch`, reload khong du. Xem muc "mot file, bon nguoi doc, hai
# thoi diem" trong CLAUDE.md.
#
# Path literal la co y o day: ta MUON no vao store luc eval, vi dconf von la
# san pham cua eval. Day khong phai truong hop agenix (chuoi tuyet doi).
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.toml);

  idFor = e:
    if builtins.hasAttr "gnome" e
    then e.gnome
    else e.id;

  # <Ctrl><Super><Alt> = Cap, them <Shift> la lop 2. Truoc day GNOME khong co
  # lop 2 vi dconf khong lam duoc chord hai tang; modifier don thi lam duoc.
  rows =
    map (e: {
      inherit (e) key;
      id = idFor e;
      mods = "<Ctrl><Super><Alt>";
    })
    (data.app or [])
    ++ map (e: {
      inherit (e) key;
      id = idFor e;
      mods = "<Ctrl><Super><Alt><Shift>";
    })
    (data.shift or []);

  bound = builtins.filter (r: r.id != "") rows;

  base = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";

  entries =
    lib.imap0 (i: r: {
      name = "${base}/custom${toString i}";
      value = {
        name = "Beckon ${r.id}";
        binding = "${r.mods}${r.key}";
        command = ''beckon "${r.id}"'';
      };
    })
    bound;
in
  {
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings =
      map (e: "/${e.name}/") entries;
  }
  // lib.listToAttrs entries
