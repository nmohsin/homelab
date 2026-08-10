{ pkgs, ports, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
    };

    oci-containers = {
      backend = "docker";

      containers.gluetun = {
        image = "ghcr.io/qdm12/gluetun";
        environment = {
          VPN_SERVICE_PROVIDER = "custom";
          VPN_TYPE = "wireguard";
          VPN_PORT_FORWARDING = "on";
          VPN_PORT_FORWARDING_PROVIDER = "protonvpn";
          VPN_PORT_FORWARDING_STATUS_FILE = "/tmp/gluetun/forwarded_port";
        };
        volumes = [
          "/etc/secrets/protonvpn.conf:/gluetun/wireguard/wg0.conf:ro"
          "/var/lib/gluetun:/tmp/gluetun"
        ];
        ports = [ "${toString ports.qbittorrent}:${toString ports.qbittorrent}" ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
        ];
      };

      containers.qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent";
        environment = {
          PUID = "1000";
          PGID = "994";
          TZ = "America/Los_Angeles";
          WEBUI_PORT = "8080";
        };
        volumes = [
          "/data/downloads:/downloads"
          "/data/qbittorrent/config:/config"
        ];
        extraOptions = [
          "--network=container:gluetun"
        ];
        dependsOn = [ "gluetun" ];
      };

      # Watches Gluetun's forwarded_port file and syncs qBittorrent's listen port via WebAPI.
      # Shares gluetun's netns so it reaches qBittorrent as localhost (bypass-auth works).
      containers.qbit-port-sync = {
        image = "ghcr.io/hononeko/qbit-gluetun-sync:latest";
        environment = {
          QBIT_ADDR = "http://localhost:8080";
          PORT_FILE = "/tmp/gluetun/forwarded_port";
        };
        volumes = [
          "/var/lib/gluetun:/tmp/gluetun:ro"
        ];
        extraOptions = [
          "--network=container:gluetun"
        ];
        dependsOn = [
          "gluetun"
          "qbittorrent"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun 0755 root root -"
  ];
}
