{lib}: let
  apps = [
    {
      key = "b";
      app = "Vivaldi";
    }
    {
      key = "c";
      app = "Claude";
    }
    {
      key = "d";
      app = "Discord";
    }
    {
      key = "g";
      app = "Google Gemini";
    }
    {
      key = "k";
      app = "Google Keep";
    }
    {
      key = "m";
      app = "Messenger";
    }
    {
      key = "n";
      app = "Notion";
    }
    {
      key = "t";
      app = "Telegram Web";
    }
    {
      key = "y";
      app = "YouTube";
    }
    {
      key = "z";
      app = "Zalo";
    }
    {
      key = "space";
      app = "kitty";
    }
  ];
  base = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";
  entries =
    lib.imap0 (i: {
      key,
      app,
    }: {
      name = "${base}/custom${toString i}";
      value = {
        name = "Beckon ${app}";
        binding = "<Ctrl><Super><Alt>${key}";
        command = ''beckon "${app}"'';
      };
    })
    apps;
in
  {
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings =
      map (e: "/${e.name}/") entries;
  }
  // lib.listToAttrs entries
