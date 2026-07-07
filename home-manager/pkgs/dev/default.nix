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
    gh
    git
    hugo
    just
    lazydocker
    ripdrag
    worktrunk
  ] ++ [
    agenix.packages.${system}.default
  ];
}
