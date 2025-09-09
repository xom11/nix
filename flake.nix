{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixgl.url = "github:nix-community/nixGL";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    ibus-bamboo.url = "github:BambooEngine/ibus-bamboo";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { ... }@inputs:
    let
      libx = import ./lib { inherit inputs ; }; 

    in
    {
      darwinConfigurations = {
        "macmini" = libx.mkDarwin {
          device = "macmini";
        };
      };
      nixosConfigurations = {
        "x1g6" = libx.mkNixos {
          device = "x1g6";
        };
      };
      # homeConfigurations = {
      #   "server" = home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     extraSpecialArgs = args // {
      #       device = "server";
      #     };
      #     modules = [
      #       ./hosts/server/home.nix
      #       nixvim.homeModules.nixvim
      #       agenix.homeManagerModules.default
      #     ];
      #   };
      #   "desktop" = home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     extraSpecialArgs = args // {
      #       device = "desktop";
      #     };
      #     modules = [
      #       nixvim.homeModules.nixvim
      #       agenix.homeManagerModules.default
      #       ./hosts/desktop/home.nix
      #     ];
      #   };
      # };
      # systemConfigs = {
      #   "desktop" = system-manager.lib.makeSystemConfig {
      #     extraSpecialArgs = specialArgs // {
      #       device = "desktop";
      #     };
      #     modules = [
      #       ./system-manager
      #     ];
      #   };
      # };
    };
  }