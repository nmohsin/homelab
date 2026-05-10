{ config, pkgs, ... }:

{
  services.prowlarr.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;

  networking.firewall.allowedTCPPorts = [
    8096  # Jellyfin
    8989  # Sonarr
    7878  # Radarr
    9696  # Prowlarr
    8080  # qBittorrent
  ];
}
