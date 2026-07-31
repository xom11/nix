{
  config,
  lib,
  pkgs,
  system,
  agenix,
  mkModule,
  ...
}: let
  publicKeys = import ./keys.nix;
  recipients = pkgs.writeText "agenix-recipients" (
    builtins.concatStringsSep "\n" publicKeys + "\n"
  );

  identityPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  secretsNix = "${config.home.homeDirectory}/.nix/home-manager/programs/agenix/secrets.nix";

  # agenix only decrypts when its launchd agent (systemd unit on linux) is
  # reloaded, i.e. on a switch. Every consumer points `file` at the working
  # tree rather than a path literal, so the ciphertext is never frozen into the
  # store and this script can re-decrypt whatever is on disk right now.
  #
  # The mapping is baked in at build time rather than read from a manifest:
  # adding a secret is a Nix change that needs a switch either way, changing
  # one's contents is not.
  secrets = lib.attrValues config.age.secrets;
  # Index-aligned bash arrays rather than generated `case` arms: the lookup
  # then lives in the script, where it can try more than one spelling of an
  # argument and where a failure can be counted instead of aborting the run.
  mkArray = name: f: "${name}=(${lib.concatMapStringsSep " " (s: lib.escapeShellArg (f s)) secrets})";

  reload = pkgs.writeShellApplication {
    name = "agenix-reload";
    runtimeInputs = [config.age.package pkgs.coreutils];
    text = ''
      identity_file="$HOME/.config/agenix/identity"
      if [ ! -r "$identity_file" ]; then
        echo "agenix-reload: cannot read $identity_file" >&2
        exit 1
      fi
      identity="$(head -n1 "$identity_file")"

      ${mkArray "SRC" (s: toString s.file)}
      ${mkArray "DST" (s: s.path)}
      ${mkArray "MODE" (s: s.mode)}

      tmp=
      trap 'if [ -n "$tmp" ]; then rm -f "$tmp"; fi' EXIT

      # Every failure path below is explicit. reload_all invokes this with
      # errexit suppressed -- one unreadable secret must not abort the rest --
      # so a failing command no longer stops the function by itself.
      reload_one() {
        local src="$1" target="$2" mode="$3" dest
        # Resolve through agenix's generation symlink so its layout survives.
        # When that chain is broken -- macOS prunes $TMPDIR eventually -- fall
        # back to the target itself and leave a real file there; the next
        # switch relinks it.
        dest="$(readlink -f "$target" 2>/dev/null)" || dest=
        [ -n "$dest" ] || dest="$target"
        mkdir -p "$(dirname "$dest")" || return 1

        # Decrypt to a sibling temp file first: a failure here must leave the
        # previous plaintext untouched rather than truncate it. The name is
        # dot-prefixed because consumers glob these directories -- ssh/config
        # Includes ~/.ssh/age.d/*, so a leftover from a hard kill would be read
        # as a second config forever.
        tmp="$(mktemp "$(dirname "$dest")/.agenix-reload.XXXXXX")" || return 1
        if ! age -d -i "$identity" "$src" > "$tmp"; then
          rm -f "$tmp"
          tmp=
          echo "agenix-reload: decrypt failed: $src" >&2
          return 1
        fi
        if ! { chmod "$mode" "$tmp" && mv -f "$tmp" "$dest"; }; then
          rm -f "$tmp"
          tmp=
          echo "agenix-reload: install failed: $target" >&2
          return 1
        fi
        tmp=
        echo "agenix-reload: $target"
      }

      reload_all() {
        local i failed=0
        for i in "''${!SRC[@]}"; do
          if ! reload_one "''${SRC[i]}" "''${DST[i]}" "''${MODE[i]}"; then
            failed=$((failed + 1))
          fi
        done
        if [ "$failed" -gt 0 ]; then
          echo "agenix-reload: $failed of ''${#SRC[@]} secrets failed" >&2
          return 1
        fi
      }

      reload_named() {
        local arg="$1" resolved i
        # Match the argument as given first: if the repo is reached through a
        # symlink, that literal form is what Nix baked into SRC, and it is what
        # nvim passes. Canonical form is the fallback, so `agenix-reload
        # apikey.zsh.age` from inside age.d/ hits the same entry instead of
        # silently reporting it undeclared.
        resolved="$(realpath "$arg" 2>/dev/null)" || resolved=
        for i in "''${!SRC[@]}"; do
          if [ "$arg" = "''${SRC[i]}" ] ||
            { [ -n "$resolved" ] && [ "$resolved" = "''${SRC[i]}" ]; }; then
            reload_one "''${SRC[i]}" "''${DST[i]}" "''${MODE[i]}"
            return
          fi
        done
        # secrets.nix rules cover every *.age in the tree, but only some are
        # wired into age.secrets. Editing one of the others is not an error.
        echo "agenix-reload: $arg is not a declared secret, skipping" >&2
      }

      case "''${1-}" in
        "" | all) reload_all ;;
        *) reload_named "$1" ;;
      esac
    '';
  };
in
  mkModule config ./. {
    home.packages = [
      pkgs.age
      agenix.packages.${system}.default
      pkgs.gnupg
      pkgs.mkpasswd
      pkgs.pass
      reload
    ];

    age.identityPaths = [identityPath];

    # agenix ships KeepAlive = { Crashed = false; SuccessfulExit = false; }.
    # launchd ORs those conditions, and `Crashed = false` means "relaunch
    # whenever it exits for any reason other than a crash" -- always true for a
    # job that exits 0. Hence a relaunch every ~10s forever: 34k generations
    # and a 4.7 MB log on macmini, plus every `agenix-reload` result silently
    # overwritten within seconds.
    #
    # Drop only that key. `SuccessfulExit = false` is the one upstream wanted:
    # retry while the decrypt keeps failing, stop once it succeeds. A fresh
    # machine generates its own id_ed25519 (see programs/ssh) which cannot
    # decrypt anything, so without the retry it would need a manual
    # `agenix-reload` after the real key is dropped in.
    #
    # That retry is blind -- launchd just relaunches on a non-zero exit, it
    # does not watch the key -- so a host with agenix enabled and no usable
    # key retries until the session ends. Nothing accumulates on disk (the
    # generation counter only advances on success, so every failed run reuses
    # the same directory), but the logs do, at a measured 425 bytes a go.
    # ThrottleInterval stretches launchd's 10s floor to a minute: a fresh
    # machine still heals on its own, a misconfigured one costs ~600 KB/day
    # instead of ~3.7 MB. `agenix-reload` is there when a minute is too long.
    launchd.agents.activate-agenix.config = {
      KeepAlive = lib.mkForce {SuccessfulExit = false;};
      ThrottleInterval = 60;
    };

    # Plain-text artefacts for the nvim transparent-edit plugin
    home.file.".config/agenix/recipients".source = recipients;
    home.file.".config/agenix/identity".text = identityPath + "\n";

    # Lets `agenix` CLI locate the rules file from any CWD
    home.sessionVariables.RULES = secretsNix;
  }
