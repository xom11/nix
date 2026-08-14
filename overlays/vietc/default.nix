# Viet+ (vietc) — bo go tieng Viet kieu "direct input" cho Linux.
#
# Khac moi bo go khac trong repo nay o CHO DUNG TANG NAO: fcitx5-lotus la client
# cua khung IME, nen trong terminal no buoc phai dung preedit (gach chan) — kitty
# khong co surrounding text de IME sua lui tai cho. vietc khong di qua IBus/Fcitx
# ma phat thang phim that, giong Go Nhanh tren macOS (CGEventTap) va VKey tren
# Windows (WH_KEYBOARD_LL + SendInput). Do la ly do duy nhat de dong goi no.
#
# Upstream KHONG commit Cargo.lock, nen lock nam canh file nay va duoc noi vao
# luc build. Bump rev thi phai sinh lai lock: `cargo generate-lockfile`.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  dbus,
  libxkbcommon,
  libx11,
  libxtst,
}:
rustPlatform.buildRustPackage {
  pname = "vietc";
  # Upstream chua tag ban nao; version lay tu daemon/Cargo.toml + ngay commit.
  version = "0.1.8-unstable-2026-07-13";

  src = fetchFromGitHub {
    owner = "vndangkhoa";
    repo = "vietc";
    rev = "13132a01c8818cd41166445725e7ec646c4f3fda";
    hash = "sha256-UGrKUl6Oa+rlLS2J4Ol0RDSBVwxCJsyrjvB/yHMweSc=";
  };

  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    ln -sf ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  # dbus: crate `dbus` link libdbus that. libxkbcommon: crate `xkbcommon` link
  # that va binary ghi SONAME libxkbcommon.so.0.
  buildInputs = [
    dbus
    libxkbcommon
  ];

  # Test nay spawn xclip/wl-copy that, khong co trong sandbox nen luon truot.
  # Ba test con lai cua daemon (ke ca vni_simple_word_grabbed) van chay.
  checkFlags = ["--skip=clipboard_read_write"];

  # libX11/libXtst KHONG duoc link luc build — `protocol/src/x11_{capture,inject}.rs`
  # goi dlopen("libX11.so.6") va dlopen("libXtst.so.6") luc chay. Tren NixOS khong
  # co /usr/lib nen dlopen se truot va vietc lang le rot xuong duong khac (hoac
  # chet), vi vay phai bom LD_LIBRARY_PATH vao wrapper.
  postInstall = ''
    for bin in $out/bin/*; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libx11 libxtst]}
    done
  '';

  meta = {
    description = "Bo go tieng Viet direct-input cho Linux (khong preedit, khong gach chan)";
    homepage = "https://github.com/vndangkhoa/vietc";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "vietc";
  };
}
