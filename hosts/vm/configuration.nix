
{ pkgs, ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      environments.enable = true;
      kanata.enable = true;
    };
  };

  # `virtualisation.vmware.guest` tao mot systemd .mount kieu fuse cho vmblock
  # (keo-tha + clipboard host<->guest). Unit do chay `mount -t fuse <binary>`,
  # ma util-linux phai co trinh tro giup `mount.fuse` moi hieu kieu do -- goi
  # `fuse` khong nam trong closure cua module, nen mount chet voi
  # "wrong fs type, bad option, bad superblock" va `switch-to-configuration`
  # tra ve 4 => MOI lan `nixos-rebuild switch` deu bao that bai du da ap xong.
  #
  # Goi thang binary thi mount duoc, nen loi nam o trinh tro giup chu khong o
  # vmblock. Dat `fuse` vao systemPackages de /run/current-system/sw/bin/mount.fuse
  # ton tai -- do la thu muc `mount` thuc su tra (PATH truyen tay bi bo qua vi
  # /run/wrappers/bin/mount la setuid nen rua sach moi truong).
  environment.systemPackages = [ pkgs.fuse ];
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
