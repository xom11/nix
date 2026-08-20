{ pkgs, lib, username, ... }:
let
  # This host exists to answer one question: on an unfamiliar machine, do nix and
  # the install scripts work? So it follows the REAL $HOME rather than guessing by
  # OS convention -- the machine may be Termux, a container, or a corporate box
  # with home somewhere else.
  envHome = builtins.getEnv "HOME";
in
{
  imports = [
    ../../home-manager
  ];

  # mkForce is REQUIRED: home-manager/base derives home.homeDirectory from the
  # TARGET system, and the two agree only when the evaluating machine's $HOME
  # matches that convention -- otherwise a cross-system eval dies with
  # "conflicting definition values".
  #
  # CI never catches this: its Linux runner makes both sides agree, so it is
  # always green. It only appears when evaluating `minimal` for x86_64-linux from
  # a Mac, which eval.yml does not do.
  #
  # The fallback covers an empty $HOME by using base's own formula rather than
  # handing home-manager an empty path.
  home.homeDirectory = lib.mkForce (
    if envHome != ""
    then envHome
    else if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}"
  );
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      zsh.enable = true;
      ssh.enable = true;
    };
  };
}
