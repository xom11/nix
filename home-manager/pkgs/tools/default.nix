{
  config,
  pkgs,
  agenix,
  system,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    ansible
    codespell
    hugo
    lazydocker
    ripdrag
    worktrunk
    caligula
    vim
  ] ++ [
    agenix.packages.${system}.default
  ];
}

