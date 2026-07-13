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

  # Target of every mkOutOfStoreSymlink. Must be a writable working tree:
  # falling back to the store copy would make dotfiles read-only and leave
  # them dangling after the next GC (the symlink is a plain string, so the
  # store path is not a reference of the home-manager generation).
  # home-manager/base clones the repo here before the link phase.
  repoPath = "${homeDir}/.nix";

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

  # Local packages (../overlays) + flake-shipped overlays. Applied at the
  # system level for darwin/nixos and to the pkgs built by mkHomeManager, so
  # `pkgs.<tool>` resolves the same way under every builder.
  allOverlays = [(import ../overlays)] ++ flakeOverlays;

  # Flake inputs every home-manager config imports, regardless of builder.
  # Declared once — a module added here reaches darwin, nixos and standalone.
  hmModules = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeModules.nixvim
    inputs.agenix.homeManagerModules.default
    inputs.nix-apt.homeManagerModules.default
  ];

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
        {nixpkgs.overlays = allOverlays;}
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
          # Reuse the system pkgs (already carries allOverlays + allowUnfree)
          # instead of letting home-manager instantiate nixpkgs a second time.
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports =
            hmModules ++ [../hosts/${device}/home.nix];
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
        {nixpkgs.overlays = allOverlays;}
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports =
            hmModules ++ [../hosts/${device}/home.nix];
        }
      ];
    };
  # =====================================================================
  # Home Manager
  # =====================================================================
  mkHomeManager = {device}:
    inputs.home-manager.lib.homeManagerConfiguration {
      # Standalone HM does not honour `nixpkgs.overlays` set inside modules —
      # `pkgs` is provided here rather than constructed by HM itself.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = allOverlays;
        config.allowUnfree = true;
      };
      extraSpecialArgs = mkArgs device;
      modules = hmModules ++ [../hosts/${device}/home.nix];
    };
  # =====================================================================
  # System Manager
  # =====================================================================
  # NOTE: keep the arg set explicit. Splatting `inputs` in here would shadow
  # system-manager's own `_module.args.system-manager` with the flake input of
  # the same name, and the activation script resolves to a bogus path.
  mkSystemManager = {device, system}:
    inputs.system-manager.lib.makeSystemConfig {
      specialArgs = {
        inherit device system mkModule ckModule;
      };
      modules = [
        ../hosts/${device}/configuration.nix
      ];
    };
}
