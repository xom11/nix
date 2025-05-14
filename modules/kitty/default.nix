{ pkgs, config, ... }:
{
  # Define the path to the kitty configuration file
  
  # Enable the kitty program
  programs.kitty = {
    enable = true;
    keybindings ={
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste-from-clipboard";
    }
    settings = {
      font_family = "Fira Code";
      font_size = 12.0;
      background_opacity = 0.8;
      cursor_shape = "block";
      cursor_blink_interval = 500;
      cursor_blink_while_typing = true;
      background_opacity = 0.8;
      enable_blur = 0.8;
      remember_window_size = true;
    };

  };
}