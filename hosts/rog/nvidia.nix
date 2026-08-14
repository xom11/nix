{ config, ... }:
{
  # ASUS ROG Strix G531GT — Optimus. Intel UHD 630 day man hinh, NVIDIA chi
  # bat khi duoc goi thang.
  #
  # Bus ID doc tu /sys/bus/pci/devices tren chinh may nay, khong phai doan:
  #   0000:00:02.0  vendor 0x8086 device 0x3e9b  -> UHD Graphics 630
  #   0000:01:00.0  vendor 0x10de device 0x1f91  -> TU117M [GTX 1650 Mobile]
  # Sai bus ID thi X khong len, va trieu chung la man hinh den — khong co
  # thong bao loi nao chi ra nguyen nhan.
  services.xserver.videoDrivers = [ "nvidia" ];

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
