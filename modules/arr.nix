{ config, pkgs, ... }:

{
  services.prowlarr.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.jellyfin.enable = true;

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr";
    environment = {
      LOG_LEVEL = "info";
      TZ = "America/Los_Angeles";
    };
    ports = [ "8191:8191" ];
  };

  networking.firewall.allowedTCPPorts = [
    8096  # Jellyfin
    8989  # Sonarr
    7878  # Radarr
    9696  # Prowlarr
    8080  # qBittorrent
    8191  # FlareSolverr
  ];
}
