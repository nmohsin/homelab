{
  config,
  pkgs,
  ports,
  ...
}:
let
  host = "moyfii.tail083295.ts.net";

  servicesYaml = pkgs.writeText "homepage-services.yaml" ''
    - Media:
        - Jellyfin:
            icon: jellyfin.png
            href: http://${host}:${toString ports.jellyfin}
            description: Media server
            ping: http://${host}:${toString ports.jellyfin}
        - Jellyseerr:
            icon: jellyseerr.png
            href: http://${host}:${toString ports.jellyseerr}
            description: Media requests
            ping: http://${host}:${toString ports.jellyseerr}
        - Sonarr:
            icon: sonarr.png
            href: http://${host}:${toString ports.sonarr}
            description: TV shows
            ping: http://${host}:${toString ports.sonarr}
        - Radarr:
            icon: radarr.png
            href: http://${host}:${toString ports.radarr}
            description: Movies
            ping: http://${host}:${toString ports.radarr}
        - Prowlarr:
            icon: prowlarr.png
            href: http://${host}:${toString ports.prowlarr}
            description: Indexers
            ping: http://${host}:${toString ports.prowlarr}
        - Bazarr:
            icon: bazarr.png
            href: http://${host}:${toString ports.bazarr}
            description: Subtitles
            ping: http://${host}:${toString ports.bazarr}
    - Downloads:
        - qBittorrent:
            icon: qbittorrent.png
            href: http://${host}:${toString ports.qbittorrent}
            description: Torrent client (via ProtonVPN)
            ping: http://${host}:${toString ports.qbittorrent}
        - FlareSolverr:
            icon: flaresolverr.png
            href: http://${host}:${toString ports.flaresolverr}
            description: Cloudflare bypass
            ping: http://${host}:${toString ports.flaresolverr}
    - Documents:
        - Paperless-ngx:
            icon: paperless-ngx.png
            href: http://${host}:${toString ports.paperless}
            description: Document management
            ping: http://${host}:${toString ports.paperless}
        - Nextcloud:
            icon: nextcloud.png
            href: http://${host}:${toString ports.nextcloud}
            description: File sync and sharing
            ping: http://${host}:${toString ports.nextcloud}
    - System:
        - CPU:
            icon: mdi-cpu-64-bit
            description: CPU usage
            widget:
              type: customapi
              url: http://${host}:${toString ports.prometheus}/api/v1/query?query=round(100+-+avg(rate(node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B5m%5D))+*+100%2C+0.1)
              refreshInterval: 30000
              mappings:
                - field: data.result.0.value.1
                  label: CPU
                  format: float
                  suffix: "%"
        - RAM:
            icon: mdi-memory
            description: RAM usage
            widget:
              type: customapi
              url: http://${host}:${toString ports.prometheus}/api/v1/query?query=round((1+-+node_memory_MemAvailable_bytes+%2F+node_memory_MemTotal_bytes)+*+100%2C+0.1)
              refreshInterval: 30000
              mappings:
                - field: data.result.0.value.1
                  label: RAM
                  format: float
                  suffix: "%"
        - Disk:
            icon: mdi-harddisk
            description: /data usage
            widget:
              type: customapi
              url: http://${host}:${toString ports.prometheus}/api/v1/query?query=round((1+-+node_filesystem_avail_bytes%7Bmountpoint%3D%22%2Fdata%22%7D+%2F+node_filesystem_size_bytes%7Bmountpoint%3D%22%2Fdata%22%7D)+*+100%2C+0.1)
              refreshInterval: 30000
              mappings:
                - field: data.result.0.value.1
                  label: /data
                  format: float
                  suffix: "%"
    - Monitoring:
        - Uptime Kuma:
            icon: uptime-kuma.png
            href: http://${host}:${toString ports.uptimekuma}
            description: Service uptime monitoring
            ping: http://${host}:${toString ports.uptimekuma}
        - Grafana:
            icon: grafana.png
            href: http://${host}:${toString ports.grafana}
            description: Metrics dashboards
            ping: http://${host}:${toString ports.grafana}
        - Prometheus:
            icon: prometheus.png
            href: http://${host}:${toString ports.prometheus}
            description: Metrics collection
            ping: http://${host}:${toString ports.prometheus}
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
    extraOptions = [ ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.homepage ];
}
