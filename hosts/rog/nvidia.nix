{ config, ... }:
{
  # ASUS ROG Strix G531GT — Optimus.
  #
  # CANH BAO, do 19/08/2026: cong HDMI cua may nay noi vao NVIDIA, khong phai
  # Intel. Man LG UltraFine 4K — man hinh DUY NHAT dang dung, vi hyprland.conf
  # tat han eDP-1 — nam o `card0-HDMI-A-1`, tuc card NVIDIA. Cho nen dung doc
  # `prime.offload` ben duoi thanh "Intel day man hinh": no chi dung cho tam
  # eDP gan lien, thu khong con ai bat.
  #
  # Bus ID doc tu /sys/bus/pci/devices tren chinh may nay, khong phai doan:
  #   0000:00:02.0  vendor 0x8086 device 0x3e9b  -> UHD Graphics 630
  #   0000:01:00.0  vendor 0x10de device 0x1f91  -> TU117M [GTX 1650 Mobile]
  # Sai bus ID thi X khong len, va trieu chung la man hinh den — khong co
  # thong bao loi nao chi ra nguyen nhan.
  services.xserver.videoDrivers = [ "nvidia" ];

  # =========================================================================
  # Hai muc duoi day cung phuc vu mot viec: cho phien Wayland render TREN
  # NVIDIA, card dang cam man hinh. Xem `env = AQ_DRM_DEVICES` trong
  # home-manager/environments/hyprland/hypr.d/hyprland.conf — day la nua he
  # thong cua no, thieu mot trong hai la nua kia vo nghia.
  # =========================================================================

  # Nap nvidia som. Do 19/08/2026 tren chinh may nay, `dmesg` + `systemd-analyze`:
  #
  #   [ 1.928] Initialized i915 1.6.0 for 0000:00:02.0 on minor 1
  #   [ 7.948] display-manager.service active          <- GDM len
  #   [ 7.972] NVRM: loading NVIDIA UNIX x86_64 Kernel Module 595.91.07
  #   [10.020] Initialized nvidia-drm 0.0.0 for 0000:01:00.0 on minor 0
  #
  # Module NVIDIA truoc day chi duoc udev nap luc 7.97s, va nvidia-drm mai
  # 10.02s moi xong — SAU khi GDM da len 2 giay. Vi `nixos/base` bat
  # `displayManager.autoLogin`, phien khoi dong ngay khi GDM san sang, nen
  # aquamarine diem danh GPU luc card NVIDIA chua ton tai: log ghi
  # "Found 1 GPUs / Registered gpu /dev/dri/card1", roi NVIDIA vao sau bang
  # "udev: new udev add event for card0" va chi con duoc lam GPU phu.
  #
  # `boot.kernelModules` chu khong phai `boot.initrd.kernelModules`: chi can
  # som hon GDM (7.95s), ma systemd-modules-load chay tu ~1-2s la du. Nap
  # trong initrd la cach manh tay hon, de danh neu cach nay chua du.
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Ten on dinh, KHONG chua dau hai cham, tro toi card NVIDIA.
  #
  # Vi sao khong dung thang `/dev/dri/card0`: so minor la thu vo tinh. simpledrm
  # giu minor 0 tu 0.57s roi nha ra luc ban giao, i915 lay minor 1 luc 1.93s,
  # va nvidia-drm nhat lai minor 0 con trong luc 10.02s. Doi thu tu nap la doi
  # so — ma muc `boot.kernelModules` ngay tren DANG doi thu tu nap.
  #
  # Vi sao khong dung `/dev/dri/by-path/pci-0000:01:00.0-card`, von dinh danh
  # dung theo bus: AQ_DRM_DEVICES tach danh sach bang dau `:`
  # (aquamarine 0.13.0, `CVarList(explicitGpus, 0, ':', true)`), ma chinh ten
  # by-path co san ba dau `:` ben trong. Se vo.
  #
  # Symlink thi an toan: aquamarine goi `std::filesystem::canonical` len CA HAI
  # ve truoc khi so sanh, nen no phan giai ve dung devnode that.
  #
  # Bus ID lay tu `prime` ben duoi, cung mot gia tri da do tren may.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia-card"
  '';

  hardware.nvidia = {
    modesetting.enable = true;

    # Can cho suspend/resume. Thieu no thi may thuc day tu sleep voi GPU o
    # trang thai hong.
    powerManagement.enable = true;

    # TAT co y. finegrained tat han GPU khi khong dung (tiet kiem pin that su)
    # nhung tren Turing van hay ken, va khi hong thi hong luc thuc day may chu
    # khong hong luc boot — rat kho noi la do no. Bat sau khi may chay on dinh.
    powerManagement.finegrained = false;

    # TU117 la Turing nen module MO chay duoc, nhung module dong van la duong
    # duoc di nhieu nhat cho doi card nay.
    open = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      # offload chu khong phai sync: Intel giu man hinh, NVIDIA ngu cho toi khi
      # co `nvidia-offload <app>`. Day la che do it rui ro nhat cho Optimus —
      # `sync` bat NVIDIA chay lien tuc va la cau hinh hay lam den man hinh nhat
      # tren may khong co MUX switch.
      offload = {
        enable = true;
        enableOffloadCmd = true; # sinh lenh `nvidia-offload`
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
