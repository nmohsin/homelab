{
  config,
  pkgs,
  ...
}:
let
  # ntfy.sh is a public service — anyone who knows this topic can subscribe.
  # Use a hard-to-guess name or run a self-hosted ntfy instance.
  ntfyTopic = "homelab-moyfii-zfs";

  zedNotify = pkgs.writeShellScript "zed-ntfy" ''
    # ZED calls: prog [email_opts] email_addr < body
    # Ignore args; use ZED environment variables for context instead.
    BODY=$(cat)
    TITLE="ZFS ''${ZEVENT_CLASS:-event} on ''${ZEVENT_POOL:-tank}"
    ${pkgs.curl}/bin/curl -sf \
      -H "Title: $TITLE" \
      -H "Priority: high" \
      -d "$BODY" \
      "https://ntfy.sh/${ntfyTopic}" || true
  '';
in
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "tank" ];
  };

  # Generate with: head -c 8 /etc/machine-id
  # Required by ZFS on NixOS — set this after running the command on the target machine
  networking.hostId = "a086514d";

  # Automated snapshots — snapshots are copy-on-write and use minimal space
  # for a media library where files are written once and rarely modified.
  # Frequent and hourly snapshots are disabled — not useful for this workload.
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 0; # disable 15-minute snapshots
    hourly = 0; # disable hourly snapshots
    daily = 7; # keep 7 daily snapshots
    weekly = 4; # keep 4 weekly snapshots
    monthly = 3; # keep 3 monthly snapshots
  };

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.log";
    ZED_NOTIFY_VERBOSE = true;
    ZED_EMAIL_ADDR = "zfs@localhost";
    ZED_EMAIL_PROG = toString zedNotify;
  };
}
