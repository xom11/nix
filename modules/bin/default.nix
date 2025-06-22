{pkgs,...}:
{
home.packages = with pkgs; [
  (writeShellScriptBin "add-authkey" (builtins.readFile ./add-authkey.sh))
  (writeShellScriptBin "add-visudo" (builtins.readFile ./add-visudo.sh))
  (writeShellScriptBin "set-zsh" (builtins.readFile ./set-zsh.sh))
  (writeShellScriptBin "install-docker" (builtins.readFile ./install-docker.sh))
  (writeShellScriptBin "update" (builtins.readFile ./update.sh))
  ];
}