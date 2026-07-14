{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # No home.packages: pkgs.herdr does not build on darwin. Its build.rs shells
    # out to `zig build` for a vendored libghostty-vt, and zig's SDK discovery
    # wants xcrun + system libtool, neither of which exists in the nix sandbox
    # (DarwinSdkNotFound). herdr is installed out-of-band via upstream's
    # installer; this module only owns the config. Revisit once nixpkgs ships a
    # darwin build (numtide/llm-agents.nix works around it with release binaries).
    #
    # Symlink the single file, not ~/.config/herdr: that directory is also where
    # the running server keeps herdr.sock, session.json and its logs.
    home.file = {
      ".config/herdr/config.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/herdr.d/config.toml";
      };
    };
  }
