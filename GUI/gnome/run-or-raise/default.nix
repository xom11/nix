{config, ...}:
{
  xdg.configFile."run-or-raise/_shortcuts.conf" = {
    text = builtins.readFile ./shortcuts.conf; 
    onChange = ''
      cp ${config.xdg.configHome}/run-or-rise/_shortcuts.conf ${config.xdg.configHome}/run-or-rise/shortcut.conf
      chmod u+w ${config.xdg.configHome}/run-or-rise/shortcut.conf
    '';
  };
}