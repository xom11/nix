{
  lib,
  config,
  pkgs,
  device,
  getPath,
  mkModule,
  ...
}: let
  zshDir = "${config.xdg.configHome}/zsh/zsh.d";
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      "${zshDir}" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/zsh.d";
      };
    };
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # historySubstringSearch.enable = true;
      history = {
        path = "${config.xdg.configHome}/zsh/.zsh_history";
        ignoreDups = true;
        ignoreAllDups = true;
        save = 1000000;
        size = 1000000;
      };
      oh-my-zsh = {
        enable = true;
        # theme = "robbyrussell";
        plugins = [
          # https://github.com/ohmyzsh/ohmyzsh/wiki/plugins
          "git"
          "extract" # extract <filename>
          "copyfile" # copyfile <filename>
          "copypath" # copypath <file_or_directory>
          "fzf"
          # "uv"
          "zoxide" # z (like cd)
          "sudo" # press esec twice
          "rust"
        ];
      };
      plugins =
        [
          {
            name = "fzf-tab";
            src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          }
          {
            name = "powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
            file = "powerlevel10k.zsh-theme";
          }
        ];
      sessionVariables = {
      };

      initContent = ''
        if [ -d "${zshDir}" ]; then
          for config_file in "${zshDir}"/*.zsh; do
            if [ -f "$config_file" ]; then
              source "$config_file"
            fi
          done
        fi

        ${lib.optionalString pkgs.stdenv.isDarwin ''
          [ -f "${zshDir}/os/macos.zsh" ] && source "${zshDir}/os/macos.zsh"
        ''}
        ${lib.optionalString pkgs.stdenv.isLinux ''
          [ -f "${zshDir}/os/linux.zsh" ] && source "${zshDir}/os/linux.zsh"
        ''}

        for f in "${pwd}"/age.d/*.age; do
          [ -f "$f" ] && source <(age -d -i ~/.ssh/id_ed25519 "$f" 2>/dev/null)
        done

        }

      '';
    };
  }
