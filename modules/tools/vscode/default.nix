{config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.kln = {
      extensions = with pkgs.vscodeExtensions; [
        ms-python.python
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter
        ms-vscode.cpptools
        ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        ms-vscode.js-debug
        ms-vscode.node-debug2
        ms-vscode.node-debug
        ms-vscode.vscode-typescript-tslint-plugin
        ms-vscode.vscode-typescript-next
        eamodio.gitlens
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];
    }

  };
}