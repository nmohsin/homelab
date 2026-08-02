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
        };
        volumes = [
          "/etc/secrets/protonvpn.conf:/gluetun/wireguard/wg0.conf:ro"
        ];
        ports = [ "${toString ports.qbittorrent}:${toString ports.qbittorrent}" ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
        ];
      };

      containers.qbittorrent = {
        # Pinned to 4.6.7: qBittorrent 5.x's /api/v2/auth/login returns 204
        # empty body instead of "Ok." body, which breaks Readarr's login
        # response check (upstream fix stalled since project is unmaintained).
        image = "lscr.io/linuxserver/qbittorrent:4.6.7";
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
    };
  };
}
