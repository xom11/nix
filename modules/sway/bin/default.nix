{...}:
{
  home.packages = with pkgs;
    let
      scriptFiles = [
        ./i3-focus
      ];
    in
    map (file: (writeShellScriptBin (builtins.baseNameOf file) (builtins.readFile file))) scriptFiles;
}