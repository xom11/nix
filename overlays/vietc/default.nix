# Viet+ (vietc) -- a direct-input Vietnamese IME for Linux.
#
# It differs from the others here in WHICH LAYER it sits at: fcitx5-lotus is an IME
# framework client, so in a terminal it must fall back to preedit (underlining),
# since kitty offers no surrounding text. vietc bypasses IBus/Fcitx and injects real
# keys, like GoNhanh on macOS and VKey on Windows. That is the only reason to
# package it.
#
# Upstream does not commit Cargo.lock, so the lock lives beside this file and is
# wired in at build time. Bumping rev means regenerating it.
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
  # Upstream has no tags; version from daemon/Cargo.toml plus the commit date.
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

  # Both are real links: the `dbus` and `xkbcommon` crates link the C libraries.
  buildInputs = [
    dbus
    libxkbcommon
  ];

  # This test spawns a real xclip/wl-copy, absent in the sandbox. The daemon's
  # other three still run.
  checkFlags = ["--skip=clipboard_read_write"];

  # libX11/libXtst are NOT linked at build time -- the X11 backends dlopen them at
  # runtime. NixOS has no /usr/lib, so that dlopen fails and vietc silently falls
  # back or dies; hence LD_LIBRARY_PATH in the wrapper.
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
