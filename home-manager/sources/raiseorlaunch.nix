{ config, pkgs, lib, device, ... }:

let
  cfg = config.modules.sources.raiseorlaunch;
  python3Packages = pkgs.python3Packages;
  raiseorlaunch = python3Packages.buildPythonApplication {
    pname = "raiseorlaunch";
    version = "0.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "khanhkhanhlele";
      repo = "raiseorlaunch";
      rev = "main";
      hash = "sha256-JqcT9sCSuKkHbhqvIrriPl/dPgc0awu6+8pvEmy2Qbg=";
    };
    pyproject = true;
    build-system = with python3Packages; [ setuptools ];
    pythonPath = with python3Packages; [ i3ipc ];
    doCheck = false;
    pythonImportsCheck = [ "raiseorlaunch" ];
  };
in
{
  options.modules.sources.raiseorlaunch = {
    enable = lib.mkEnableOption "Enable raiseorlaunch utility";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      raiseorlaunch
    ];
  };
}