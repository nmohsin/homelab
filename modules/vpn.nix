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
        ports = [
          "${toString ports.qbittorrent}:${toString ports.qbittorrent}"
          "${toString ports.mousehole}:${toString ports.mousehole}"
        ];
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

      # Keeps MyAnonaMouse's dynamic seedbox IP in sync with Gluetun's egress IP.
      # Must share gluetun's netns so update requests originate from the VPN IP
      # that MAM should register — otherwise the reported IP diverges from
      # qBittorrent's traffic and MAM flags the session.
      containers.mousehole = {
        image = "tmmrtn/mousehole:latest";
        environment = {
          TZ = "America/Los_Angeles";
          MOUSEHOLE_PORT = toString ports.mousehole;
          MOUSEHOLE_UPDATE_INTERVAL_SECONDS = "300";
          MOUSEHOLE_ALLOWED_HOSTS = "moyfii.tail083295.ts.net:${toString ports.mousehole},localhost:${toString ports.mousehole}";
          # Mousehole >=0.5.0 refuses to boot without auth unless explicitly opted out.
          # Access to the UI is already gated by tailscale0 (same trust model as qBittorrent).
          MOUSEHOLE_INSECURE_ALLOW_NO_AUTH = "true";
        };
        volumes = [
          "/var/lib/mousehole:/var/lib/mousehole"
        ];
        extraOptions = [
          "--network=container:gluetun"
        ];
        dependsOn = [ "gluetun" ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun 0755 root root -"
    "d /var/lib/mousehole 0755 root root -"
  ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.mousehole ];
}
