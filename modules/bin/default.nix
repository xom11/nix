{...}:
{
  home.file = {
    ".local/bin/add-authkey" = {source = ./add-authkey; executable = true;};
    ".local/bin/add-visudo".source = ./add-visudo;
    ".local/bin/set-default-shell".source = ./set-default-shell;
  };
  home.sessionVariables.PATH = [
    "$HOME/.local/bin"
  ];
}