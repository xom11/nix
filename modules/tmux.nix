{pkgs, config, ...}
{
  programs.tmux = {
    enable = true;
    enableCopyMode = true;
    enableMouse = true;
    enablePlugins = true;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
    ];
  };
}