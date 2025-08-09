# File: ./nvitop.nix
{ pkgs, ... }:

let
  btcli-package = pkgs.python3Packages.buildPythonApplication rec {
    pname = "btcli";
    version = "9.10.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "opentensor";
      repo = "btcli";
      rev = "v${version}";
      hash = "sha256-kUlKb5L8dzT4ESi0rO2v0kQPwqckyfbk=";
    };

    build-system = with pkgs.python3Packages; [ setuptools ];

    pythonRelaxDeps = [ "" ];

    dependencies = with pkgs.python3Packages; [
    ];

    doInstallCheck = true;
    nativeInstallCheckInputs = [
      pkgs.versionCheckHook
    ];
    versionCheckProgramArg = "--version";

    # pythonImportsCheck = [ "nvitop" ];

    meta = {
    #   description = "Interactive NVIDIA-GPU process viewer, the one-stop solution for GPU process management";
    #   homepage = "https://github.com/XuehaiPan/nvitop";
    #   changelog = "https://github.com/XuehaiPan/nvitop/releases/tag/v${version}";
    #   license = pkgs.lib.licenses.gpl3;
    #   maintainers = with pkgs.lib.maintainers; [ GaetanLepage ];
    #   platforms = pkgs.lib.platforms.linux;
    };
  };
in
{
    home.packages = with pkgs; [
        btcli-package
    ];
}