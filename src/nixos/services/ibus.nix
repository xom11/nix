{ config, pkgs, lib, ... }:

let
  ibus-bamboo = pkgs.stdenv.mkDerivation rec {
    pname = "ibus-bamboo";
    version = "0.8.4-dev3";

    src = pkgs.fetchFromGitHub {
      owner = "goatastronaut0212";
      repo = pname;
      rev = "7d95126114aa1d54cee801164a66928ce404e144";
      sha256 = "sha256-clBMzz+yZ7lQKD1Me99qmzsATklbPpermea5nonRLc0=";
    };

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.wrapGAppsHook3
      pkgs.go
    ];

    buildInputs = [
      pkgs.xorg.libXtst
    ];

    preConfigure = ''
      export GOCACHE="$TMPDIR/go-cache"
      sed -i "s,/usr,$out," data/bamboo.xml
    '';

    makeFlags = [
      "PREFIX=${placeholder "out"}"
    ];

    meta = {
      isIbusEngine = true;
      description = "A Vietnamese IME for IBus";
      homepage = "https://github.com/BambooEngine/ibus-bamboo";
      license = lib.licenses.gpl3;
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [ astronaut0212 ];
    };
  };
in
{
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = [
      ibus-bamboo
    ];
  };
}
