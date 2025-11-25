{ inputs, ... }:

let
  system = builtins.currentSystem;
  lib = inputs.nixpkgs.lib;

  username = let
    checkUser = user: user != "" && user != "root" && user != "nixos";
    sudoUser = builtins.getEnv "SUDO_USER";
    normalUser = builtins.getEnv "USER";
  in
    if checkUser sudoUser
    then sudoUser
    else if checkUser normalUser
    then normalUser
    else "kln";

  homeDir =
    if builtins.match ".*-darwin" system != null
    then "/Users/${username}"
    else "/home/${username}";

  rootPath = let
    absPath = "${homeDir}/.nix";
    relPath = "../.nix";
  in
    if builtins.pathExists absPath
    then absPath
    else relPath;

  device = "";

  getRelPath = path: let
    # Step 1: /nix/store/* -> /nix/store/*-source/relPath
    nixPath = builtins.toString path;
    # Step 2: split by "-source/"
    relPath = builtins.elemAt (lib.strings.splitString "-source/" nixPath) 1;
  in
    relPath;

  getPath = path: "${rootPath}/${getRelPath path}";

  # Create module: option + config
  mkModule = config: path: moduleContent: let
    relPath = getRelPath path;
    pathList = ["modules"] ++ (lib.splitString "/" relPath);
    cfg = lib.getAttrFromPath pathList config;
  in {
    options = lib.setAttrByPath pathList {
      enable = lib.mkEnableOption "Enable ${relPath}";
    };

    config = lib.mkIf cfg.enable moduleContent;
  };

  # Check module: check cfg in not default.nix <nixvim/modules>
  ckModule = config: path: cfgContent: let
    relPath = getRelPath path;
    pathList = ["modules"] ++ (lib.splitString "/" relPath);
    cfg = lib.getAttrFromPath pathList config;
  in {
    config = lib.mkIf cfg.enable cfgContent;
  };

in {
  inherit lib username homeDir rootPath device getRelPath getPath mkModule ckModule;
}
