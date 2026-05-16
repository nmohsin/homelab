{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.gluetun = {
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
    ports = [ "8080:8080" ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/net/tun"
      "--restart=unless-stopped"
    ];
  };

  virtualisation.oci-containers.containers.qbittorrent = {
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
      "--restart=unless-stopped"
    ];
    dependsOn = [ "gluetun" ];
  };
}
