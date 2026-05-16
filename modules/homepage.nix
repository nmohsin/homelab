{ config, pkgs, ... }:

{
  environment.etc."homepage/services.yaml".text = ''
    - Media:
        - Jellyfin:
            icon: jellyfin.png
            href: http://moyfii:8096
            description: Media server
        - Sonarr:
            icon: sonarr.png
            href: http://moyfii:8989
            description: TV shows
        - Radarr:
            icon: radarr.png
            href: http://moyfii:7878
            description: Movies
        - Prowlarr:
            icon: prowlarr.png
            href: http://moyfii:9696
            description: Indexers
    - Downloads:
        - qBittorrent:
            icon: qbittorrent.png
            href: http://moyfii:8080
            description: Torrent client (via ProtonVPN)
        - FlareSolverr:
            icon: flaresolverr.png
            href: http://moyfii:8191
            description: Cloudflare bypass
  '';

  environment.etc."homepage/settings.yaml".text = ''
    title: moyfii
    theme: dark
    color: slate
    headerStyle: clean
    hideVersion: true
    language: en
  '';

  environment.etc."homepage/widgets.yaml".text = ''
    - datetime:
        text_size: xl
        format:
          timeStyle: short
          dateStyle: short
  '';

  environment.etc."homepage/bookmarks.yaml".text = "---";
  environment.etc."homepage/docker.yaml".text = "---";
  environment.etc."homepage/custom.css".text = "";
  environment.etc."homepage/custom.js".text = "";

  virtualisation.oci-containers.containers.homepage = {
    image = "ghcr.io/gethomepage/homepage:latest";
    volumes = [
      "/etc/homepage:/app/config"
    ];
    ports = [ "3000:3000" ];
    extraOptions = [];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3000 ];
}
