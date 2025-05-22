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
      username = builtins.getEnv "SUDO_USER"; 
      useremail = "__USEREMAIL__";
      hostname = "__HOSTNAME__";

      specialArgs =
        inputs
        // {
          inherit username useremail hostname;
        };
    in
    {
    darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      system = "aarch64-darwin";
      modules = [
        ./hosts/macos/configuration.nix
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = username;
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
          };
        }
        home-manager.darwinModules.home-manager {
            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./hosts/macos/home.nix ;
        }
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [ 
        ./hosts/nixos/configuration.nix 
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = [ 
            nix-flatpak.homeManagerModules.nix-flatpak
            ./hosts/nixos/home.nix
           ];
        }
      ];
    };
    # homeConfigurations = {
    #   "macos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    #     modules = [ ./hosts/macos/home.nix ];
    #   };
    #   "nixos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #     modules = [ ./hosts/nixos/home.nix ];
    #   };
    # };
  };
}