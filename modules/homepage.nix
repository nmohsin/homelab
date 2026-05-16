{ config, pkgs, ports, ... }:

let
  host = "moyfii.tail083295.ts.net";

  servicesYaml = pkgs.writeText "homepage-services.yaml" ''
    - Media:
        - Jellyfin:
            icon: jellyfin.png
            href: http://${host}:${toString ports.jellyfin}
            description: Media server
        - Sonarr:
            icon: sonarr.png
            href: http://${host}:${toString ports.sonarr}
            description: TV shows
        - Radarr:
            icon: radarr.png
            href: http://${host}:${toString ports.radarr}
            description: Movies
        - Prowlarr:
            icon: prowlarr.png
            href: http://${host}:${toString ports.prowlarr}
            description: Indexers
    - Downloads:
        - qBittorrent:
            icon: qbittorrent.png
            href: http://${host}:${toString ports.qbittorrent}
            description: Torrent client (via ProtonVPN)
        - FlareSolverr:
            icon: flaresolverr.png
            href: http://${host}:${toString ports.flaresolverr}
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
    environment = {
      HOMEPAGE_ALLOWED_HOSTS = "moyfii:${toString ports.homepage},${host}:${toString ports.homepage}";
    };
    volumes = [
      "/var/lib/homepage:/app/config"
    ];
    ports = [ "${toString ports.homepage}:${toString ports.homepage}" ];
    extraOptions = [];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.homepage ];
}
