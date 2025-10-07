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
      lib = import ./lib { inherit inputs ; }; 

    in
    {
      darwinConfigurations = {
        macmini = lib.mkDarwin { device = "macmini"; };
      };
      nixosConfigurations = {
        x1g6 = lib.mkNixos { device = "x1g6"; };
      };
      homeConfigurations = {
        server = lib.mkHomeManager { device = "server"; };
        desktop = lib.mkHomeManager { device = "desktop"; };
      };
      systemConfigs = {
        desktop = lib.mkSystemManager { device = "desktop"; };
      };
    };
  }
