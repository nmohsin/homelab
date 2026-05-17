{ ports, ... }:
{
  services = {
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    jellyfin.enable = true;
    bazarr.enable = true;
  };

  systemd.services = {
    prowlarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/prowlarr" ];
      };
    };
    sonarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/sonarr"
          "/data/downloads"
          "/data/media/tv"
        ];
      };
    };
    radarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/radarr"
          "/data/downloads"
          "/data/media/movies"
        ];
      };
    };
    jellyfin = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
        ];
        ReadOnlyPaths = [ "/data/media" ];
      };
    };
    bazarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/bazarr"
          "/data/media/tv"
          "/data/media/movies"
        ];
      };
    };
  };

  users.users = {
    sonarr.extraGroups = [ "media" ];
    radarr.extraGroups = [ "media" ];
    jellyfin.extraGroups = [ "media" ];
    bazarr.extraGroups = [ "media" ];
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr";
    environment = {
      LOG_LEVEL = "info";
      TZ = "America/Los_Angeles";
    };
    ports = [ "${toString ports.flaresolverr}:${toString ports.flaresolverr}" ];
    extraOptions = [ ];
  };

  # Restrict service ports to Tailscale interface only — not reachable from local network
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    ports.jellyfin
    ports.sonarr
    ports.radarr
    ports.prowlarr
    ports.qbittorrent
    ports.bazarr
    ports.flaresolverr
  ];
}
