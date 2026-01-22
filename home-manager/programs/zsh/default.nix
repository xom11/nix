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
          "extract"     # extract <filename>
          "copyfile"    # copyfile <filename>
          "copypath"    # copypath <file_or_directory>
          "fzf"
          # "uv"
          "zoxide"      # z (like cd)
          "sudo"        # press esec twice
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
        ]
        ++ lib.optional (device != "server")
        {
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        };
      dirHashes = {
        # cd ~cfg
        cfg = "$HOME/.config";
        pass = "$HOME/.password-store";
        dev = "$HOME/Documents/dev";
        note = "$HOME/Documents/note";
        test = "$HOME/Documents/test";
        tmp = "$HOME/Documents/tmp";
        nix = "$HOME/.nix";
        ssd = "/Volumes/ssd";
        dotfiles = "$HOME/.nix/home-manager/dotfiles";
        secrets = "$HOME/.nix/home-manager/dotfiles/secrets";
      };

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

        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
        ZVM_SYSTEM_CLIPBOARD_ENABLED=true
        zvm_after_init() {
          source ${config.programs.fzf.package}/share/fzf/key-bindings.zsh

          # fix Alt + key not working
          bindkey '\e[1;3D' backward-word
          bindkey '\e[1;3C' forward-word
          bindkey '\e\x7f' backward-kill-word

          # fix other in https://github.com/jeffreytse/zsh-vi-mode/issues/288
          bindkey '^[' zvm_readkeys_handler
          bindkey '^[^[' sudo-command-line
          bindkey '^[OA' up-line-or-beginning-search
          bindkey '^[OB' down-line-or-beginning-search
          bindkey '^[OC' vi-forward-char
          bindkey '^[OD' vi-backward-char
          bindkey '^[OF' end-of-line
          bindkey '^[OH' beginning-of-line
          bindkey '^[[1;5C' forward-word
          bindkey '^[[1;5D' backward-word
          bindkey '^[[200~' bracketed-paste
          bindkey '^[[3;5~' kill-word
          bindkey '^[[3~' delete-char
          bindkey '^[[5~' up-line-or-history
          bindkey '^[[6~' down-line-or-history
          bindkey '^[[A' up-line-or-beginning-search
          bindkey '^[[B' down-line-or-beginning-search
          bindkey '^[[C' vi-forward-char
          bindkey '^[[D' vi-backward-char
          bindkey '^[[F' end-of-line
          bindkey '^[[H' beginning-of-line
          bindkey '^[[Z' reverse-menu-complete
          bindkey '^[c' fzf-cd-widget
        }

      '';
    };
  }
