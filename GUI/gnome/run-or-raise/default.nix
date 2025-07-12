{config, ...}:
{
  xdg.configFile."run-or-raise/shortcut.conf".source = ./shortcut.conf;
  xdg.configFile."run-or-raise/_shortcuts.conf" = {
    text = builtins.readFile ./shortcuts.conf; 
    onChange = ''
      rm -f ${config.xdg.configHome}/run-or-rise/shortcut.conf
      cp ${config.xdg.configHome}/run-or-rise/_shortcuts.conf ${config.xdg.configHome}/run-or-rise/shortcut.conf
      chmod u+w ${config.xdg.configHome}/run-or-rise/shortcut.conf
    '';
  };
}