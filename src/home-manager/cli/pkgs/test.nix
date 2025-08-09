{ pkgs, ... }:

let
  nvitop-package = pkgs.python3Packages.buildPythonApplication rec {
    pname = "nvitop";
    version = "1.5.2";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "XuehaiPan";
      repo = "nvitop";
      rev = "v${version}";
      # Hash chưa đúng, sẽ bị lỗi
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    build-system = with pkgs.python3Packages; [ setuptools ];

    dependencies = with pkgs.python3Packages; [
      psutil
      nvidia-ml-py
    ];
  };
in
# Chỉ cần trả về gói để có thể build
nvitop-package