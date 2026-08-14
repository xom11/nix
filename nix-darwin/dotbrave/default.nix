# Ban song sinh darwin cua nixos/services/dotbrave -- doc ghi chu day du o do.
#
# Tom tat: mot dong `modules.nix-darwin.dotbrave.enable = true` bat CA HAI nua
# cua dotbrave. `[pwa]` di qua darwinModules (ghi managed policy tai
# /Library/Managed Preferences, ma darwin-rebuild von chay bang root nen khong
# hoi sudo giua activation); `[shortcuts]` + `[settings]` di qua module
# home-manager anh em, chay o quyen user voi `skip = ["pwa"]`.
#
# Khac ban NixOS o dung mot cho: duong policy. darwin ghi plist, khong phai file
# JSON duoi /etc -- day la viec cua upstream, module nay khong chon duong.
#
# Rieng darwin co mot bay khong co ben Linux: module nay THAY THE plist chu
# khong merge, nen may nao co MDM profile dat cac khoa policy Brave khac se mat
# chung. macmini khong co MDM.
{
  config,
  dotbrave,
  mkModule,
  repoPath,
  username,
  ...
}:
{
  imports = [dotbrave.darwinModules.default];
}
// mkModule config ./. {
  services.dotbrave = {
    enable = true;
    config = "${repoPath}/home-manager/dotfiles/browser/dotbrave/brave.toml";
  };

  home-manager.users.${username}.modules.home-manager.dotfiles.browser.dotbrave.enable = true;
}
