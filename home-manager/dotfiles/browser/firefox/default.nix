{
  config,
  lib,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  homeDir = config.home.homeDirectory;

  profilesRelDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".mozilla/firefox"
    else "Library/Application Support/Firefox/Profiles";

  profilesAbsDir = "${homeDir}/${profilesRelDir}";

  profiles =
    if builtins.pathExists profilesAbsDir
    then builtins.readDir profilesAbsDir
    else {};

  findProfile = suffix:
    let matches = builtins.filter (name: lib.hasSuffix suffix name) (builtins.attrNames profiles);
    in if matches != [] then builtins.head matches else null;

  profile = let
    release = findProfile ".default-release";
    dflt = findProfile ".default";
  in
    if release != null
    then release
    else if dflt != null
    then dflt
    else null;
in
  mkModule config ./. (lib.mkIf (profile != null) {
    home.file = {
      "${profilesRelDir}/${profile}/user.js" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/user.js";
      };
      "${profilesRelDir}/${profile}/chrome" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/chrome";
      };
    };
  })
