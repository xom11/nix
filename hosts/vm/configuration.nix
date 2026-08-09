
{ ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      environments.enable = true;
      # kanata.enable = true;
    };
  };
  # Bo chuyen tiep DNS cua VMware NAT (192.168.163.2) khong tra loi, du dinh
  # tuyen ra ngoai van tot (ping 1.1.1.1 chay). Hau qua khong hien nhien:
  # `gitclonenix` trong home-manager/base clone GitHub LUC ACTIVATION, nen
  # khong phan giai duoc ten mien => home-manager-<user>.service chet exit 128
  # => khong dotfile nao duoc tao => i3 boot ra wizard "first configuration".
  # Dat DNS cung o day de VM tu dung duoc sau moi lan reboot.
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
