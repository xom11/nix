{
  pkgs,
  config,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # nixos
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          # Thieu module Qt thi `fcitx5-diagnose` bao "Cannot find fcitx5 input
          # method module for Qt5/Qt6" va moi app Qt mat han bo go — ke ca
          # `fcitx5-lotus-settings` (Qt6). Do duoc tren rog 16/08/2026.
          # KHONG lien quan toi chuyen gach chan trong kitty: kitty khong phai
          # app Qt, no noi thang zwp_text_input_v3. Day la loi thu hai, rieng.
          #
          # KHONG co attr top-level `fcitx5-qt`; phai di qua qt6Packages
          # (kdePackages.fcitx5-qt tra ve CUNG store path). Co y chi lay Qt6:
          # libsForQt5.fcitx5-qt keo them ca closure Qt5 cho nhung app host nay
          # gan nhu khong co. Doi lai, diagnose se van than phien ve Qt5 —
          # do la danh doi, khong phai thieu sot.
          qt6Packages.fcitx5-qt
          fcitx5-lotus
        ];
        waylandFrontend = true;
        # Do not use settings so that fcitx5 UI can manage its own config
        # Config will be saved directly at ~/.config/fcitx5/
      };
    };
    home.file = {
      # dotfile
      ".config/fcitx5/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/config";
      };
      ".config/fcitx5/profile" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/profile";
      };
      # Config cua rieng addon lotus. Thu DUY NHAT dang ke trong file nay la
      # `Mode`: mac dinh bien dich san cua addon la `Preedit` — mot trong dung
      # HAI che do co gach chan. Do duoc 19/08/2026: tang he thong da xanh tu
      # `cb0c7db9` (server chay, /dev/uinput co ACL, thiet bi ao ton tai) nhung
      # khong ai chuyen sang Uinput, nen van gach chan. Dat `Uinput (Smooth)`
      # la het, da do tren may.
      #
      # Gia tri hop le la TEN HIEN THI, do bang cach thu tung cai:
      #   OFF | Uinput (Smooth) | Uinput (Slow) | Uinput (Super Smooth)
      #   Surrounding Text | Preedit | Emoji Picker | Minecraft
      # `ModeOrder` ben duoi dung ten NGAN (Smooth, SurroundingText...) — do la
      # thu tu menu, mot khong gian ten KHAC. Ghi `Mode=Smooth` thi bi fcitx5 da
      # ve `Preedit` ma khong bao gi ca.
      #
      # `FixUinputWithAck=True` trong file: che do Uinput ban BackSpace THAT va
      # bat dong bo, nen app Chromium co o nhap tu ve lai bi ROT KY TU. Day la
      # cong tac upstream cho dung trieu chung do — nhung DA THU VA TRUOT tren
      # Messenger. Giu True vi vo hai va co the cuu app Chromium khac; dung
      # tuong no da giai quyet xong chuyen rot ky tu (xem lotus-app-rules.conf).
      #
      # CANH BAO PHAM VI: file nay dung chung cho ca ba host bat i18n
      # (desktop, rog, vm) nhung CHI rog bat `modules.nixos.services.fcitx5-lotus`
      # — tang he thong cap server + udev. desktop la standalone home-manager
      # nen khong the nap unit do. Hai host kia se nhan che do Uinput MA KHONG
      # co server; hau qua CHUA DUOC DO. Neu chung go hong, cach sua la them
      # luat rieng theo host chu dung sua file nay.
      ".config/fcitx5/conf/lotus.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/lotus.conf";
      };
      # Luat rieng theo app. File RIENG, khong nam trong lotus.conf — de sot no
      # thi luat bien mat ma khong bao gi.
      #
      # Messenger la web app cua Facebook (chay trong PWA cua Brave, nhan
      # Chromium). O soan tin cua no khong theo kip BackSpace bom nhanh nen ROT
      # KY TU. Do het cac che do tren may 19/08/2026, qua menu ` (grave):
      #
      #   Uinput (Super Smooth)  rot nhieu
      #   Uinput (Smooth)        rot
      #   Uinput (Slow)          rot IT HON, VAN ROT   <-- dang dung
      #   Surrounding Text       HONG HAN, khong go ra tieng Viet
      #   Preedit                sach, nhung CO gach chan
      #
      # KHONG co che do nao vua sach vua khong gach chan. Day la danh doi that,
      # khong phai cho chua van dung: chu may DA CHON `Slow` (chiu rot ky tu de
      # khoi gach chan). Muon doi y thi sua so o file .conf thanh 5 (Preedit),
      # hoac bam ` roi q de thu ngay.
      #
      # Vi lam CHAM chi lam rot IT HON chu khong het, dung di theo huong "ha toc
      # do them nua" — cuoc dua nay khong dong lai duoc bang cach do.
      # `FixUinputWithAck=True` cung KHONG cuu duoc, du upstream mo ta dung
      # trieu chung nay — da thu va truot. Van de True vi vo hai.
      #
      # Hai bay o day, ca hai deu im lang khi sai:
      #  - Mode trong file nay la MA SO (2 = Uinput (Slow)), khac hoan toan
      #    `Mode` toan cuc von la TEN HIEN THI ("Uinput (Smooth)").
      #  - fcitx5 KHONG kiem tra ma nay: ghi 99 van duoc nhan va luu. Nen doc
      #    lai chi chung minh "da luu", khong chung minh "hop le".
      #
      # App id lay tu chinh lotus (no tu ghi luat khi bam phim tat), trung voi
      # ten file .desktop bo phan duoi. CHUA phu: messenger.com mo trong tab
      # Brave THUONG van rot ky tu, vi tab do mang app id khac. Muon phu thi
      # phai dat luat cho ca Brave, doi lai la ca trinh duyet cham theo.
      ".config/fcitx5/conf/lotus-app-rules.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/lotus-app-rules.conf";
      };
      # X11 (i3wm)
      ".xprofile".text = ''
        export XMODIFIERS="@im=fcitx"
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export SDL_IM_MODULE=fcitx
        export GLFW_IM_MODULE=ibus
      '';
    };
    # Wayland (sway) — sessionVariables are set via systemd user environment
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
    };
  }
