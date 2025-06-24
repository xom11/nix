{...}:
{
  home.activation = {
    installApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${./install.sh}
    '';
  };
}