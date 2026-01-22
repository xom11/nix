{
  config,
  agenix,
  system,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = [
    agenix.packages.${system}.default
    pkgs.age
    pkgs.gnupg
    pkgs.pass
  ];
  age = {
    secrets = {
      "secret".file = ./secrets.d/secret.age;
      "zsh".file = ./secrets.d/zsh.age;
      "zsh-keys" = {
        file = ./secrets.d/zsh-keys.age;
      };
      "git-credentials" = {
        file = ./secrets.d/git-credentials.age;
        path = "${config.home.homeDirectory}/.git-credentials";
      };
    };
    identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
  };
  programs.zsh.initContent = ''
    if [ -f "${config.age.secrets.zsh-keys.path}" ]; then
      source "${config.age.secrets.zsh-keys.path}"
    fi
  '';
}
