{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];

  # Generate with: head -c 8 /etc/machine-id
  # Required by ZFS on NixOS — set this after running the command on the target machine
  networking.hostId = "a086514d";

  # Automated snapshots — snapshots are copy-on-write and use minimal space
  # for a media library where files are written once and rarely modified.
  # Frequent and hourly snapshots are disabled — not useful for this workload.
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 0;  # disable 15-minute snapshots
    hourly = 0;    # disable hourly snapshots
    daily = 7;     # keep 7 daily snapshots
    weekly = 4;    # keep 4 weekly snapshots
    monthly = 3;   # keep 3 monthly snapshots
  };

  # ZFS Event Daemon — monitors pool health and logs warnings on drive errors,
  # checksum failures, and pool state changes.
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.log";
    ZED_NOTIFY_VERBOSE = true;
  };
}
