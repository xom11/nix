{ lib, ... }:

let
  createSymlinksForDirectory = targetBase: sourceDir:
    let
      allFiles = builtins.readDir sourceDir;
      regularFiles = lib.filterAttrs (name: type: type == "regular") allFiles;
    in
    lib.mapAttrs'
      (name: type:
        {
          name = "${targetBase}/${name}";
          value = {
            source = "${sourceDir}/${name}";
            enable = true;
          };
        })
      regularFiles;

in
{
  home.file = lib.mkMerge [
    (createSymlinksForDirectory ".local/share/applications" ./applications)
    (createSymlinksForDirectory ".local/share/icons" ./icons)
  ];
}
