{
  lib,
  config,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    # Node.js
    nodejs_22
    nodemon
    pm2
    pnpm
    yarn
    bun
    live-server

    # Python
    python3
    python3Packages.pip
    uv

    # Rust
    maturin
    rustup

    # Go
    go

    # C#
    dotnetCorePackages.sdk_8_0-bin

    # DB tools
    mongosh
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    # C/C++ -- LINUX ONLY, va cai `optionals` nay la phan quan trong hon chinh
    # goi gcc. Do tren macmini 20/08/2026:
    #
    # gcc-wrapper tren darwin cung cap 13 binary trung ten voi toolchain cua
    # Apple -- cc, ld, as, ar, nm, strip, ranlib, strings, objdump, c++, g++,
    # gcc, cpp. Ma `/etc/profiles/per-user/<user>/bin` dung o vi tri 9 trong
    # PATH con `/usr/bin` mai vi tri 13, nen ca 13 cai DEU DE len ban cua Apple.
    #
    # Va no hong IM LANG: `nix build` cua home-manager-path van XANH, khong mot
    # dong collision nao, va `cc` van bien dich chay duoc mot file C tran. Cho
    # vo la SDK:
    #
    #   /usr/bin/cc fw.c -framework CoreFoundation   -> chay, in "ok"
    #   <profile>/bin/cc fw.c -framework CoreFoundation
    #     -> fatal error: CoreFoundation/CoreFoundation.h: No such file or directory
    #
    # (`ld` cung tut tu ld-1267 cua Apple ve ld64-956.6.) Nghia la moi native
    # build cham toi framework he thong -- node-gyp, cargo voi crate `*-sys`,
    # python C extension, cgo -- deu vo tren may Mac. Dung bo `optionals` nay.
    #
    # Ly do can gcc o Linux: `tree-sitter build` shell ra `cc`, va macOS lay no
    # tu Xcode CLT (NGOAI nix) nen khong module nao trong repo tung phai khai --
    # do la vi sao thieu sot nay song lau den vay. Tren rog thi khong co gi
    # cung cap `cc`, nen ca 31 parser trong `ensure` cua
    # programs/nvim/lua/plugins/treesitter.lua deu compile truot; ma install()
    # chay lai cho nhung gi CON THIEU, nen moi lan mo nvim la mot lan tai lai
    # va that bai lai ca 32 lan. Do tren rog 19/08/2026: 32 loi moi lan khoi
    # dong, 0 parser; co `cc` thi 0 loi va 31 parser (gitcommit ~4.6s, cham
    # nhat, roi vao lan mo ke tiep).
    gcc
  ];

  # npm install -g packages go to ~/.npm-global
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];
}
