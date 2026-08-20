{
  config,
  mkModule,
  getPath,
  hammerspoon-spoons,
  ...
}: let
  pwd = getPath ./.;

  # Third-party spoons from the hammerspoon-spoons input, pinned in flake.lock.
  #
  # `source = <store path>`, NOT mkOutOfStoreSymlink: the latter builds a symlink from a plain
  # string and creates no reference, so pointing it into the store loses the target at the next
  # GC. A real store path is held as a generation reference. Read-only in exchange, which is
  # right -- these are not hand-edited like MySpoons.
  #
  # Only AClock has a live consumer (Tab.spoon). RecursiveBinder is kept deliberately rather
  # than because anything needs it: its one remaining consumer, LaunchTerminal.spoon, is
  # commented out in init.lua and would need it back immediately if re-enabled.
  thirdPartySpoons = ["RecursiveBinder" "AClock"];
in
  mkModule config ./. {
    home.file =
      {
        ".hammerspoon/init.lua" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
        };
        ".hammerspoon/LibSpoons" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/LibSpoons";
        };
        ".hammerspoon/MySpoons" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pwd}/MySpoons";
        };
      }
      // builtins.listToAttrs (map (name: {
          name = ".hammerspoon/Spoons/${name}.spoon";
          value.source = "${hammerspoon-spoons}/Source/${name}.spoon";
        })
        thirdPartySpoons);
  }
