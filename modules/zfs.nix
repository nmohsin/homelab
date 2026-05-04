{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];

  # Generate with: head -c 8 /etc/machine-id
  # Required by ZFS on NixOS — set this after running the command on the target machine
  networking.hostId = "a086514d";
}
