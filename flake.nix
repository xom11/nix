{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # nix-homebrew's own brew-src pin lags: it sits on Homebrew 6.0.12
    # (2026-07-20), which predates the `command_wrapper` and `generated_script`
    # cask artifact classes. 65 casks in homebrew-cask already use them, so
    # `brew bundle` dies parsing firefox/vlc/obs mid-activation -- which leaves
    # /run/current-system pointing at the previous generation. 6.0.13 is the
    # first release shipping both. Drop this override once nix-homebrew catches
    # up (it is at upstream HEAD, so this is upstream lag, not a stale input).
    brew-src = {
      url = "github:Homebrew/brew/6.0.13";
      flake = false;
    };
    nix-homebrew.inputs.brew-src.follows = "brew-src";
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

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    # Without these, agenix drags in its own home-manager and nix-darwin (both
    # pinned months back) purely to run its own checks.
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "nix-darwin";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    beckon.url = "github:xom11/beckon";
    beckon.inputs.nixpkgs.follows = "nixpkgs";

    dotbrave.url = "github:xom11/dotbrave";
    dotbrave.inputs.nixpkgs.follows = "nixpkgs";

    # darwin-only package; its overlay is simply absent on Linux, so keeping it in
    # the shared list breaks no Linux host.
    tongue.url = "github:xom11/tongue";
    tongue.inputs.nixpkgs.follows = "nixpkgs";

    nix-apt.url = "github:xom11/nix-apt";

    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third-party Hammerspoon spoons, pinned here rather than vendored: someone
    # else's code stays out of the working tree while flake.lock still fixes the
    # rev, so it is reproducible and needs no network at startup.
    hammerspoon-spoons = {
      url = "github:Hammerspoon/Spoons";
      flake = false;
    };

  };

  outputs =
    { ... }@inputs:
    let
      # Overlays shipped by flake inputs. Add new tools here — every host
      # (darwin / nixos / standalone HM) picks them up automatically via
      # mkConfigs.nix, so `pkgs.<tool>` is available without per-host
      # wiring. Adding a new tool: declare the input above, then append
      # `inputs.<tool>.overlays.default` to this list.
      flakeOverlays = [
        inputs.beckon.overlays.default
        inputs.dotbrave.overlays.default
        inputs.tongue.overlays.default
        inputs."fcitx5-lotus".overlays.default
      ];

      lib = import ./lib { inherit inputs flakeOverlays; };

      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
      pkgsFor = system: inputs.nixpkgs.legacyPackages.${system};

    in
    {
      # Local package overlay, consumable from outside this flake. Currently EMPTY
      # (see ATTIC.md). The mechanism stays: overlays/default.nix reads the
      # directory, so a new package directory is picked up without editing this.
      overlays.default = import ./overlays;

      formatter = forAllSystems (system: (pkgsFor system).alejandra);

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [ alejandra nixd deadnix statix ];
        };
      });

      darwinConfigurations = {
        macmini = lib.mkDarwin { device = "macmini"; };
        airm3 = lib.mkDarwin { device = "airm3"; };
      };
      nixosConfigurations = {
        vm = lib.mkNixos { device = "vm"; };
        rog = lib.mkNixos { device = "rog"; };
      };
      homeConfigurations = {
        server = lib.mkHomeManager { device = "server"; };
        desktop = lib.mkHomeManager { device = "desktop"; };
        minimal = lib.mkHomeManager { device = "minimal"; };
      };
      systemConfigs = inputs.nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"] (system: {
        desktop = lib.mkSystemManager { device = "desktop"; inherit system; };
      });
    };
  }
