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
    rev = "main";
    hash = "sha256-f3F+VClpjF99yQ9KT09OY26dCxMbgdjAp1Ff33jXeVc=";
  };
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  pythonPath = with python3Packages; [ i3ipc ];
  # no tests
  doCheck = false;
  pythonImportsCheck = [ "raiseorlaunch" ];
}