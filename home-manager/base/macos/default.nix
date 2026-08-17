{
  config,
  homeDir,
  repoPath,
  mkModule,
  device,
  ...
}:
mkModule config ./. {
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };

  # Formula beckon cua Homebrew chay
  #   beckon serve ~/.config/beckon/apps.toml --log /opt/homebrew/var/log/beckon.log
  # va duong dan config do HARDCODE trong `service do` cua formula -- khong co
  # cach nao truyen duong dan khac tu day. Nen tro no ve file that trong repo.
  #
  # Truoc 17/08/2026 ca hai may lam viec nay BANG TAY, va hai ban lam tay lech
  # nhau: macmini la symlink dung, airm3 la BAN COPY ROI (dung im o 16/08 trong
  # khi file repo da di tiep) -- tuc brew serve ben do se dang ky bang bang phim
  # cu ma khong bao gi. Khai o day de khong con hai ban.
  #
  # mkOutOfStoreSymlink chu KHONG phai `source = ../../configs/...`: path literal
  # copy file vao store roi symlink toi ban READ-ONLY o do, hong hai duong mot
  # luc. Mot, sua file trong repo se khong an cho toi lan switch sau, mat dung
  # tinh chat ma "Dotfile linking pattern" trong CLAUDE.md giu. Hai, beckon tu
  # 0.8.0 GHI NGUOC vao chinh file nay (cua so Settings, config_write.rs) nen no
  # se dam vao store read-only.
  home.file."${config.xdg.configHome}/beckon/apps.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/shortcuts/apps.shared.toml";
}
