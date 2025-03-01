{ config, pkgs, lib, ... }:
let
  # limit boot entry
  configurationLimit = 10;
in with config.boot; {
  kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos;
  zfs.package = lib.mkDefault pkgs.zfs_cachyos;

  loader = with loader; {
    efi.canTouchEfiVariables = systemd-boot.enable;

    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      inherit configurationLimit;
    };

    grub = {
      inherit configurationLimit;
      enable = ! systemd-boot.enable;
      copyKernels = true;
      efiInstallAsRemovable = ! efi.canTouchEfiVariables;
      efiSupport = true;
      fsIdentifier = "label";
      zfsSupport = true;
      # device = "/dev/disk/by-id/nvme-KINGSTON_OM8PDP3256B-AB1_50026B768583ADF8-part1";
      mirroredBoots = [
        { devices = [ "nodev" ]; path = "/boot"; }
      ];
      device = "nodev";
    };
  };

  plymouth = {
    enable = true;
    theme = "bgrt";
  };

  tmp = {
    cleanOnBoot = true;
    useTmpfs = false;
  };

  kernelParams = [
    "zfs.zfs_arc_max=536870912" # max zfs cache (512MB)
  ];
  kernel.sysctl  = {
    "kernel.sysrq" = 1;
    "kernel.printk" = "3 3 3 3";
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # Enable v4l2loopback kernel module for using Virtual Camera.
  extraModulePackages = with kernelPackages; [
    v4l2loopback
  ];
  extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="Virtual Camera" exclusive_caps=1
  '';

  # kernel.sysctl = {
    # for unlimited warnet hack, thankxs to umahdroid.com
    # https://www.umahdroid.com/2023/08/trik-axis-warnet-unlimited-hotspot.html
    # "net.ipv4.ip_default_ttl" = 65;
    # "net.inet6.ip6.hlim" = 65;
  # };
}
