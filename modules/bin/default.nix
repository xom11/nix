{pkgs,...}:
{
home.packages = with pkgs; [
  (writeShellScriptBin "add-authkey" (builtins.readFile ./add-authkey))
  (writeShellScriptBin "add-visudo" (builtins.readFile ./add-visudo))
  (writeShellScriptBin "set-zsh" (builtins.readFile ./set-zsh))
  ];
}