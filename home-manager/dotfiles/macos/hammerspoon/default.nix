{
  config,
  mkModule,
  getPath,
  hammerspoon-spoons,
  ...
}: let
  pwd = getPath ./.;

  # Spoon bên thứ ba, lấy từ input hammerspoon-spoons đã ghim rev trong flake.lock.
  #
  # Dùng `source = <đường dẫn store>` chứ KHÔNG dùng mkOutOfStoreSymlink. mkOutOfStoreSymlink
  # tạo symlink từ một chuỗi thuần nên không sinh reference — trỏ vào store bằng cách đó thì
  # lần GC sau là mất. Ở đây source là store path thật, home-manager giữ nó làm reference của
  # generation nên có GC root đàng hoàng. Đổi lại là read-only, đúng ý: đây không phải dotfile
  # để sửa tay như MySpoons.
  #
  # Chỉ hai spoon này thực sự được dùng: RecursiveBinder (LaunchTerminal.spoon:15
  # gọi lúc load, thiếu là rb.singleKey thành nil) và AClock (tab+t).
  # LaunchApp.spoon TỪNG dùng RecursiveBinder cho lớp Cap+a; từ khi lớp 2 chuyển
  # sang Cap+Shift thì không còn. AllBrightness từng được nạp nhưng không bao
  # giờ start(), InputSourceSwitch chỉ phục vụ LanguageSwitcher (spoon đó nay đã xoá) — bỏ cả hai.
  thirdPartySpoons = ["RecursiveBinder" "AClock"];
in
  mkModule config ./. {
    home.file =
      {
        ".hammerspoon/init.lua" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
        };
        ".hammerspoon/LibSpoons" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/LibSpoons";
        };
        ".hammerspoon/MySpoons" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/MySpoons";
        };
      }
      // builtins.listToAttrs (map (name: {
          name = ".hammerspoon/Spoons/${name}.spoon";
          value.source = "${hammerspoon-spoons}/Source/${name}.spoon";
        })
        thirdPartySpoons);
  }
