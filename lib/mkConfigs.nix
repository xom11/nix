{ inputs, ... }:
let
  system = builtins.currentSystem;

  username =
    let
      checkUser = user: user != "" && user != "root" && user != "nixos";
      sudoUser = builtins.getEnv "SUDO_USER";
      normalUser = builtins.getEnv "USER";
    in
    if checkUser sudoUser then
      sudoUser
    else if checkUser normalUser then
      normalUser
    else
      "kln";
  homeDir =
    if builtins.match ".*-darwin" system != null then "/Users/${username}" else "/home/${username}";

  dotfileDir =
    let
      absPath = "${homeDir}/.nix/home-manager/dotfiles";
      relPath = "./home-manager/dotfiles";
    in
    if builtins.pathExists absPath then absPath else relPath;

  device = "";

  args = inputs // {
    inherit
      username
      dotfileDir
      system
      homeDir
      device
      ;
  };

in
{
  # =====================================================================
  # Nix-darwin
  # =====================================================================
  mkDarwin = { device,}:
  let
    specialArgs = args // {
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
  mkNixos = { device, }:
  let
    specialArgs = args // {
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
  mkHomeManager = { device, }:
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    extraSpecialArgs = args // {
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
  mkSystemManager = { device, }:
  let
    extraSpecialArgs = args // {
      device = device;
    };
  in
  inputs.system-manager.lib.systemManagerConfiguration {
    inherit extraSpecialArgs;
    modules = [
      ../hosts/${device}/configuration.nix
    ];
  };
}