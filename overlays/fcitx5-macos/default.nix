{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "fcitx5-macos-installer";
  version = "0.2.9";

  src = fetchurl {
    url = "https://github.com/fcitx-contrib/fcitx5-macos-installer/releases/download/${version}/Fcitx5Installer.zip";
    hash = "sha256-IFYn4FW+wVavBLdbKjC+toHoVTg+6FaNnkftgEQHTQ0="; 
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r Fcitx5Installer.app $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Installer of Fcitx5 macOS";
    homepage = "https://github.com/fcitx-contrib/fcitx5-macos-installer";
    license = licenses.mpl20;
    platforms = platforms.darwin;
    maintainers = [ ];
  };
}
