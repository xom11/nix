{
  config,
  pkgs,
  username,
  mkModule,
  ...
}:
# Tang ao hoa cho guest full-VM. KHAC voi `virtualisation.docker` o
# nixos/services/default.nix: docker bat vo dieu kien cho moi host NixOS, con
# module nay la opt-in — x1g6 va vm khong can no.
mkModule config ./. {
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # `pkgs.qemu` gia lap duoc ca kien truc khac (aarch64 tren x86); ban _kvm
      # chi mang kien truc host. Guest o day cung kien truc voi host nen phan
      # thua chi ton dia.
      package = pkgs.qemu_kvm;

      # qemu chay duoi user `qemu-libvirtd` thay vi root. Doi lai: disk phai
      # nam cho ma user do doc duoc — tuc /var/lib/libvirt/images. Dat anh dia
      # trong $HOME se la loi quyen chu khong phai loi cau hinh.
      runAsRoot = false;

      # Khong can cho guest Linux BIOS. Bat san vi day dung la khac biet duy
      # nhat giua "chay duoc Linux" va "chay duoc Windows 11" (Win11 doi TPM
      # 2.0), va them sau nghia la rebuild rog them mot lan nua.
      swtpm.enable = true;

      # KHONG dat `qemu.ovmf` o day. Submodule do da bi GO khoi nixpkgs, chi
      # con lai ba field `internal` mac dinh null va mot assertion: dat bat ky
      # field nao (ke ca `packages`) la eval do ngay voi "This submodule is
      # deprecated and has been removed". Moi anh OVMF di kem QEMU gio deu co
      # san, nen UEFI van dung duoc ma khong khai gi.
    };

    # Mac dinh la `onShutdown = "suspend"` di kem `onBoot = "start"`, nghia la
    # guest dang chay luc tat may se duoc managedsave roi TU DONG song lai o
    # lan boot sau — theo dung mo ta cua nixpkgs, "regardless of their
    # autostart settings". Tren may 7,6 GiB thi do la vai GiB RAM bien mat ma
    # khong ai bao. Doi sang "shutdown" thi khong con gi de khoi phuc, va chi
    # guest that su duoc danh dau autostart moi tu chay.
    onShutdown = "shutdown";

    # Mac dinh 300: mot guest lo ACPI treo lenh tat may cua rog nam phut.
    shutdownTimeout = 60;
  };

  # `virtualisation.libvirtd` da dua `virsh` vao PATH nhung KHONG dua
  # virt-install. nixpkgs khong co attr `virt-install` lan `virtinst` — no nam
  # trong `virt-manager` (5.1.0), keo theo ca GUI. Khong co duong vong.
  #
  # cloud-utils la cho `cloud-localds`: sinh seed ISO cloud-init de guest tu
  # nhan SSH key ngay lan boot dau, khong phai bam gi qua console.
  environment.systemPackages = [
    pkgs.virt-manager
    pkgs.cloud-utils
  ];

  users.users.${username}.extraGroups = ["libvirtd"];
}
