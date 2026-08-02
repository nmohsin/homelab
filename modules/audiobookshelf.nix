{ ports, ... }:
{
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = ports.audiobookshelf;
  };

  users.users.audiobookshelf.extraGroups = [ "media" ];

  systemd.services.audiobookshelf = {
    after = [ "zfs-import-tank.service" ];
    serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/audiobookshelf" ];
      ReadOnlyPaths = [ "/data/media" ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.audiobookshelf ];
}
