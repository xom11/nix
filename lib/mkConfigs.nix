{inputs, ...}: let
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

  repoPath = let
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

  getPath = path: "${repoPath}/${getRelPath path}";

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

  # Install apt packages on non-NixOS systems (idempotent)
  hm = inputs.home-manager.lib.hm;
  mkApt = path: packages: let
    name = builtins.replaceStrings ["/"] ["-"] (getRelPath path);
  in {
    "apt-${name}" = hm.dag.entryAfter ["writeBoundary"] ''
      if command -v apt-get &>/dev/null; then
        missing=()
        for pkg in ${lib.concatStringsSep " " packages}; do
          if ! dpkg -s "$pkg" &>/dev/null; then
            missing+=("$pkg")
          fi
        done
        if [ ''${#missing[@]} -gt 0 ]; then
          echo "Installing apt packages: ''${missing[*]}"
          sudo apt-get install -y "''${missing[@]}"
        fi
      fi
    '';
  };

  # Check module: check cfg in not default.nix <nixvim/modules>
  ckModule = config: path: cfgContent: let
    relPath = getRelPath path;
    pathList = ["modules"] ++ (lib.splitString "/" relPath);
    cfg = lib.getAttrFromPath pathList config;
  in {
    config = lib.mkIf cfg.enable cfgContent;
  };

  args =
    inputs
    // {
      inherit
        username
        system
        homeDir
        repoPath
        device
        getRelPath
        getPath
        mkModule
        mkApt
        ckModule
        ;
    };
in {
  # =====================================================================
  # Nix-darwin
  # =====================================================================
  mkDarwin = {device}: let
    specialArgs =
      args
      // {
        device = device;
      };
  in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = specialArgs;
      system = system;
      modules = [
        ../hosts/${device}/configuration.nix
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = username;
          };
        }
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = [
            inputs.nixvim.homeModules.nixvim
            inputs.agenix.homeManagerModules.default
            ../hosts/${device}/home.nix
          ];
        }
      ];
    };
  # =====================================================================
  # NixOS
  # =====================================================================
  mkNixos = {device}: let
    specialArgs =
      args
      // {
        device = device;
      };
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs;
      system = system;
      modules = [
        inputs.disko.nixosModules.disko
        ../hosts/${device}/configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${args.username}.imports = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.agenix.homeManagerModules.default
            inputs.nixvim.homeModules.nixvim
            ../hosts/${device}/home.nix
          ];
        }
      ];
    };
  # =====================================================================
  # Home Manager
  # =====================================================================
  mkHomeManager = {device}:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs =
        args
        // {
          device = device;
        };
      modules = [
        ../hosts/${device}/home.nix
        inputs.nixvim.homeModules.nixvim
        inputs.agenix.homeManagerModules.default
      ];
    };
  # =====================================================================
  # System Manager
  # =====================================================================
  mkSystemManager = {device}: let
    extraSpecialArgs =
      args
      // {
        device = device;
      };
  in
    inputs.system-manager.lib.makeSystemConfig {
      inherit extraSpecialArgs;
      modules = [
        # ../hosts/${device}/configuration.nix
        ../system-manager
      ];
    };
}
