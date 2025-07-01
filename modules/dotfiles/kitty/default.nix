{pkgs, lib, config, ...}:
{
  home.file.".config/kitty/kitty.conf" = {
    source = ./kitty.conf;
  }; 
  home.file."hello" = {
    text = "Hello, Kitty!";
  };
}