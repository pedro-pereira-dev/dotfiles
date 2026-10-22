{ ... }: {
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  disko.devices.nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };
  };

  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content.type = "gpt";

    content.partitions.esp = {
      name = "ESP";
      size = "1G";
      type = "EF00";
    };
    content.partitions.esp.content = {
      extraArgs = [
        "-n"
        "BOOT"
      ];
      format = "vfat";
      mountOptions = [ "umask=0077" ];
      mountpoint = "/boot";
      type = "filesystem";
    };

    content.partitions.swap = {
      name = "SWAP";
      size = "1G";
    };
    content.partitions.swap.content = {
      extraArgs = [
        "-L"
        "SWAP"
      ];
      resumeDevice = true;
      type = "swap";
    };

    content.partitions.root = {
      name = "ROOT";
      size = "100%";
    };
    content.partitions.root.content = {
      extraArgs = [
        "-f"
        "-L"
        "ROOT"
      ];
      type = "btrfs";
      subvolumes = {

        "/nix" = {
          mountOptions = [
            "compress=lzo"
            "noatime"
          ];
          mountpoint = "/nix";
        };

        "/persistent" = {
          mountOptions = [
            "compress=lzo"
            "noatime"
          ];
          mountpoint = "/persistent";
        };

      };
    };
  };
}
