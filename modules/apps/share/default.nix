{ pkgs, config,... }:

{

  home.packages = with pkgs; [
    # tldr
    # ansible
    # ripgrep
    # jq
    # atuin
    pipx
    caligula
    gemini-cli
  ];

}