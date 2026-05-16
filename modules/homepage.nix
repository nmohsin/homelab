{ config, pkgs, ... }:

let
  servicesYaml = pkgs.writeText "homepage-services.yaml" ''
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

  settingsYaml = pkgs.writeText "homepage-settings.yaml" ''
    title: moyfii
    theme: dark
    color: slate
    headerStyle: clean
    hideVersion: true
    language: en
  '';

  widgetsYaml = pkgs.writeText "homepage-widgets.yaml" ''
    - datetime:
        text_size: xl
        format:
          timeStyle: short
          dateStyle: short
  '';
in

{
  # Write config as real files (not symlinks) so Homepage can write alongside them.
  # cp -f overwrites on every rebuild so Nix config stays the source of truth.
  system.activationScripts.homepage-config.text = ''
    mkdir -p /var/lib/homepage
    cp -f ${servicesYaml} /var/lib/homepage/services.yaml
    cp -f ${settingsYaml} /var/lib/homepage/settings.yaml
    cp -f ${widgetsYaml} /var/lib/homepage/widgets.yaml
    touch /var/lib/homepage/bookmarks.yaml
    touch /var/lib/homepage/docker.yaml
    touch /var/lib/homepage/custom.css
    touch /var/lib/homepage/custom.js
  '';

  virtualisation.oci-containers.containers.homepage = {
    image = "ghcr.io/gethomepage/homepage:latest";
    volumes = [
      "/var/lib/homepage:/app/config"
    ];
    ports = [ "3000:3000" ];
    extraOptions = [];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3000 ];
}
