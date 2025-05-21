{
  description = "Home Manager configuration";

  # nixConfig = {
  #   experimental-features = ["nix-command" "flakes"];
  #   allowUnfree = true;
  # };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {... }@inputs:
    with inputs;
    let
      system = builtins.currentSystem;
      sudo_user = builtins.getEnv "SUDO_USER";
    in
    {
    darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macos/configuration.nix
        inputs.nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = sudo_user;
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
          };
        }
        # inputs.home-manager.darwinModules.home-manager {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #     home-manager.extraSpecialArgs = { inherit inputs; };
        #     home-manager.users.${sudo_user} = { imports = [ ./hosts/macos/home.nix ]; };
        # }
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      modules = [ 
        ./hosts/nixos/configuration.nix 
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
    homeConfigurations = {
      "macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./hosts/macos/home.nix ];
      };
      "nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./hosts/nixos/home.nix ];
      };
    };
  };
}