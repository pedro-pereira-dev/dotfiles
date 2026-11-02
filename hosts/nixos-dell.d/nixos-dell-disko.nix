{ ... }: {
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  disko.devices.nodev."/".fsType = "tmpfs";
  disko.devices.nodev."/".mountOptions = [
    "size=25%"
    "mode=755"
  ];

  disko.devices.disk.main.device = "/dev/nvme0n1";
  disko.devices.disk.main.type = "disk";
  disko.devices.disk.main.content.type = "gpt";

  disko.devices.disk.main.content.partitions.esp.name = "ESP";
  disko.devices.disk.main.content.partitions.esp.size = "1G";
  disko.devices.disk.main.content.partitions.esp.type = "EF00";
  disko.devices.disk.main.content.partitions.esp.content.extraArgs = [
    "-n"
    "BOOT"
  ];

  disko.devices.disk.main.content.partitions.esp.content.format = "vfat";
  disko.devices.disk.main.content.partitions.esp.content.mountOptions = [ "umask=0077" ];
  disko.devices.disk.main.content.partitions.esp.content.mountpoint = "/boot";
  disko.devices.disk.main.content.partitions.esp.content.type = "filesystem";

  disko.devices.disk.main.content.partitions.swap.name = "SWAP";
  disko.devices.disk.main.content.partitions.swap.size = "4G";
  disko.devices.disk.main.content.partitions.swap.content.extraArgs = [
    "-L"
    "SWAP"
  ];

  disko.devices.disk.main.content.partitions.swap.content.resumeDevice = true;
  disko.devices.disk.main.content.partitions.swap.content.type = "swap";

  disko.devices.disk.main.content.partitions.root.name = "ROOT";
  disko.devices.disk.main.content.partitions.root.size = "100%";
  disko.devices.disk.main.content.partitions.root.content.extraArgs = [
    "-f"
    "-L"
    "ROOT"
  ];

  disko.devices.disk.main.content.partitions.root.content.type = "btrfs";

  disko.devices.disk.main.content.partitions.root.content.subvolumes."/nix".mountpoint = "/nix";
  disko.devices.disk.main.content.partitions.root.content.subvolumes."/nix".mountOptions = [
    "compress=lzo"
    "noatime"
  ];

  disko.devices.disk.main.content.partitions.root.content.subvolumes."/persistent".mountpoint = "/persistent";
  disko.devices.disk.main.content.partitions.root.content.subvolumes."/persistent".mountOptions = [
    "compress=lzo"
    "noatime"
  ];
}
