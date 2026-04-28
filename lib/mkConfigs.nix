{inputs, flakeOverlays, ...}: let
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
        getRelPath
        getPath
        mkModule
        ckModule
        ;
    };
  mkArgs = device: args // {inherit device;};
in {
  # =====================================================================
  # Nix-darwin
  # =====================================================================
  mkDarwin = {device}: let
    specialArgs = mkArgs device;
  in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = specialArgs;
      system = system;
      modules = [
        ../hosts/${device}/configuration.nix
        # Flake-shipped overlays (declared in flake.nix → flakeOverlays).
        # Applied at the system level so `pkgs.<tool>` is available for
        # nix-darwin's `environment.systemPackages` etc.
        { nixpkgs.overlays = flakeOverlays; }
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
            # HM builds its own pkgs (useGlobalPkgs is unset), so the
            # system-level overlays don't reach here. Inject again.
            { nixpkgs.overlays = flakeOverlays; }
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
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
    specialArgs = mkArgs device;
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs;
      system = system;
      modules = [
        inputs.disko.nixosModules.disko
        ../hosts/${device}/configuration.nix
        # Flake-shipped overlays (declared in flake.nix → flakeOverlays).
        # System-level — for `environment.systemPackages` etc.
        { nixpkgs.overlays = flakeOverlays; }
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${args.username}.imports = [
            # HM-side overlays (HM builds its own pkgs).
            { nixpkgs.overlays = flakeOverlays; }
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
      # Construct pkgs with overlays so user packages from `../overlays`
      # (e.g. raiseorlaunch) resolve in standalone home-manager. Standalone
      # HM does not honour `nixpkgs.overlays` set inside modules because
      # `pkgs` is provided here rather than constructed by HM itself.
      #
      # Flake-shipped overlays come from `flakeOverlays` (declared in
      # flake.nix) — `nix flake update <tool>` bumps versions, no manual
      # rev/hash/Cargo.lock to maintain.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ (import ../overlays) ] ++ flakeOverlays;
        config.allowUnfree = true;
      };
      extraSpecialArgs = mkArgs device;
      modules = [
        ../hosts/${device}/home.nix
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.nixvim.homeModules.nixvim
        inputs.agenix.homeManagerModules.default
      ];
    };
  # =====================================================================
  # System Manager
  # =====================================================================
  mkSystemManager = {device, system}:
    inputs.system-manager.lib.makeSystemConfig {
      extraSpecialArgs = {
        inherit device system mkModule ckModule;
      };
      modules = [
        ../hosts/${device}/configuration.nix
      ];
    };
}
