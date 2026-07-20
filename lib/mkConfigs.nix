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

  # A module's path relative to the flake root. Every option path in the repo
  # derives from this, so it is worth not coupling it to how Nix happens to name
  # store paths: the old version split on the literal "-source/", which silently
  # produced a wrong option path for any directory nested under a `*-source` dir
  # and failed with a contextless "index out of bounds" otherwise.
  srcRoot = builtins.toString ../.;
  getRelPath = path: let
    root = "${srcRoot}/";
    p = builtins.toString path;
  in
    if lib.hasPrefix root p
    then lib.removePrefix root p
    else throw "getRelPath: ${p} is outside the flake root ${root}";

  getPath = path: "${repoPath}/${getRelPath path}";

  # Every nested default.nix under `dir`, except dir's own. This is how each
  # module root (home-manager/, nixos/, nix-darwin/, system-manager/) discovers
  # its modules -- there is no import list to maintain.
  autoImport = dir: let
    inherit (builtins) filter map toString;
    inherit (lib.filesystem) listFilesRecursive;
    inherit (lib.strings) hasSuffix;
  in
    filter (hasSuffix "/default.nix") (
      map toString (filter (p: p != dir + "/default.nix") (listFilesRecursive dir))
    );

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
        autoImport
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
        inherit device system username autoImport mkModule ckModule;
      };
      modules = [
        ../hosts/${device}/configuration.nix
        { nixpkgs.overlays = allOverlays; }
      ];
    };
}
