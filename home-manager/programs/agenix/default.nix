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

  # agenix only decrypts on a switch. Every consumer points `file` at the working
  # tree, not a path literal, so the ciphertext is never frozen into the store and
  # this script can re-decrypt what is on disk now. The mapping is baked in at
  # build time: adding a secret needs a switch anyway, editing one does not.
  secrets = lib.attrValues config.age.secrets;
  # Index-aligned arrays, not generated `case` arms, so the lookup lives in the
  # script -- it can try several spellings of an argument and count failures.
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

      # Failure paths are explicit: reload_all suppresses errexit so one
      # unreadable secret cannot abort the rest.
      reload_one() {
        local src="$1" target="$2" mode="$3" dest
        # Resolve through agenix's generation symlink to keep its layout. If
        # that chain is broken (macOS prunes $TMPDIR), write a real file at the
        # target; the next switch relinks it.
        dest="$(readlink -f "$target" 2>/dev/null)" || dest=
        [ -n "$dest" ] || dest="$target"
        mkdir -p "$(dirname "$dest")" || return 1

        # Sibling temp file first, so a failure leaves the previous plaintext
        # intact instead of truncating it. Dot-prefixed because consumers glob
        # these directories -- ssh/config Includes age.d/*, and a leftover from
        # a hard kill would be read as a second config forever.
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
        # Literal form first: that is what Nix baked into SRC when the repo is
        # reached through a symlink, and what nvim passes. Canonical form is the
        # fallback, so calling it from inside age.d/ hits the same entry.
        resolved="$(realpath "$arg" 2>/dev/null)" || resolved=
        for i in "''${!SRC[@]}"; do
          if [ "$arg" = "''${SRC[i]}" ] ||
            { [ -n "$resolved" ] && [ "$resolved" = "''${SRC[i]}" ]; }; then
            reload_one "''${SRC[i]}" "''${DST[i]}" "''${MODE[i]}"
            return
          fi
        done
        # secrets.nix covers every *.age, but only some are in age.secrets.
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

    # agenix ships `Crashed = false` alongside `SuccessfulExit = false`, and
    # launchd ORs them -- so a job exiting 0 relaunches every ~10 s forever
    # (34k generations and a 4.7 MB log on macmini), overwriting every
    # `agenix-reload` result within seconds.
    #
    # Drop only that key. `SuccessfulExit = false` is the retry upstream wanted:
    # a fresh machine's self-generated id_ed25519 decrypts nothing, so without it
    # the real key would need a manual reload after being dropped in.
    #
    # That retry is blind, so a host with no usable key retries until the session
    # ends -- 425 bytes of log per attempt. ThrottleInterval stretches launchd's
    # 10 s floor to a minute: still self-healing, ~600 KB/day instead of 3.7 MB.
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
