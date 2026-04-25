{
  config,
  lib,
  ...
}:
let
  cfg = config.home.aptPackages;
in {
  options.home.aptPackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Declarative apt packages for Debian/Ubuntu systems";
  };

  config = lib.mkIf (cfg != []) {
    home.activation.installAptPackages =
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -x /usr/bin/apt-get ]; then
          missing=()
          for pkg in ${lib.concatStringsSep " " cfg}; do
            if ! /usr/bin/dpkg -s "$pkg" &>/dev/null; then
              missing+=("$pkg")
            fi
          done
          if [ ''${#missing[@]} -gt 0 ]; then
            echo "Installing apt packages: ''${missing[*]}"
            /usr/bin/sudo /usr/bin/apt-get install -y "''${missing[@]}"
          fi
        fi
      '';
  };
}
