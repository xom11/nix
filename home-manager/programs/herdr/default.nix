{
  pkgs,
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # nixpkgs now builds herdr on darwin too: pkgs/by-name/he/herdr adds cctools
    # and xcbuild on isDarwin, which is exactly the xcrun + libtool that zig's SDK
    # discovery used to miss in the sandbox (DarwinSdkNotFound). Prebuilt in
    # cache.nixos.org for aarch64-darwin, x86_64-linux and aarch64-linux, so no
    # host compiles the vendored libghostty-vt.
    #
    # The trade-off of owning it here: `herdr update` and `herdr channel` cannot
    # work against a read-only store path. Upgrades come from a nixpkgs bump, so
    # this pins every host to one version instead of tracking upstream releases.
    # Anyone who wants the self-updater back drops this line and reinstalls
    # out-of-band -- but then mind that ~/.local/bin precedes the nix profile in
    # PATH, so a leftover binary there silently shadows this one.
    home.packages = [
      pkgs.herdr

      # Receiving half of the Windows screenshot bridge; the sending half lives in
      # dotfiles/windows (pwsh ps1.d/herdr-clip.ps1 + ahk/herdr-clip.ahk).
      #
      # It no longer needs herdr or jq: the path is typed on the Windows side now,
      # into the window that is actually focused there, so nothing on this end
      # talks to a Herdr server. Kept in this module anyway because this is where
      # the feature is documented and every host that wants it already enables
      # herdr -- but the script itself would work on a box with no herdr at all.
      # runtimeInputs pins base64/od/find to the GNU flavours it was written
      # against rather than whatever PATH offers on darwin.
      (pkgs.writeShellApplication {
        name = "herdr-clip-recv";
        runtimeInputs = [pkgs.coreutils pkgs.findutils];
        text = builtins.readFile ./herdr-clip-recv;
      })
    ];

    # Symlink individual files, not ~/.config/herdr: that directory is also where
    # the running server keeps herdr.sock, session.json and its logs.
    home.file = {
      ".config/herdr/config.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/herdr.d/config.toml";
      };

      # Local detection-manifest override; see the header of the file itself.
      # A local override always wins over the bundled and remote manifests, so
      # this one pins Claude Code detection until it is re-synced by hand.
      ".config/herdr/agent-detection/claude.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/herdr.d/agent-detection/claude.toml";
      };
    };
  }
