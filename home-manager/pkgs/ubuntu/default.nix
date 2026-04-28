{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  services.nix-apt = {
    enable = true;
    aptPackages = [
      "kitty"
      "flatpak"
      "gnome-software-plugin-flatpak"
    ];
  };

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "org.videolan.VLC"
      "org.telegram.desktop"
      "com.sindresorhus.Caprine"
      "org.localsend.localsend_app"
    ];
  };
}
