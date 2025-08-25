{ fetchFromGitHub, pkgs, ... }:

let
  python3Packages = pkgs.python3Packages;
in
python3Packages.buildPythonPackage {
  pname = "raiseorlaunch";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "khanhkhanhlele";
    repo = "raiseorlaunch";
    rev = "";
  };
  pyproject = true;
  build-system = [
    python3Packages.setuptools
  ];
  pythonPath = with python3Packages; [ i3ipc ];

}