{
  ports,
  pkgs,
  ...
}:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "moyfii.tail083295.ts.net";
    home = "/data/nextcloud";
    maxUploadSize = "10G";
    configureRedis = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = "/data/nextcloud/initial-admin-password";
      adminuser = "admin";
    };

    database.createLocally = true;

    settings = {
      overwriteprotocol = "http";
      trusted_domains = [
        "moyfii.tail083295.ts.net"
        "moyfii"
      ];
      default_phone_region = "US";
    };
  };

  services.nginx.virtualHosts."moyfii.tail083295.ts.net" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = ports.nextcloud;
      }
    ];
  };

  systemd.services = {
    nextcloud-setup.after = [ "zfs-import-tank.service" ];
    phpfpm-nextcloud.after = [ "zfs-import-tank.service" ];
    nginx.after = [ "zfs-import-tank.service" ];
  };

  system.activationScripts.nextcloud-dirs.text = ''
    mkdir -p /data/nextcloud
    if [ ! -f /data/nextcloud/initial-admin-password ]; then
      echo "changeme-on-first-login" > /data/nextcloud/initial-admin-password
      chmod 600 /data/nextcloud/initial-admin-password
    fi
  '';

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.nextcloud ];
}
