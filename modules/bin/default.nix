{pkgs,...}:
{
home.packages = with pkgs;
  let
    scriptFiles = [
      ./add-authkey
      ./add-visudo
      ./set-zsh
      ./i3-focus
    ];
  in
  map (file: (writeShellScriptBin (builtins.baseNameOf file) (builtins.readFile file))) scriptFiles;
}