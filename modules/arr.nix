{ports, ...}: {
  services = {
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    jellyfin.enable = true;
  };

  systemd.services = {
    prowlarr.after = ["zfs-import-tank.service"];
    sonarr.after = ["zfs-import-tank.service"];
    radarr.after = ["zfs-import-tank.service"];
    jellyfin.after = ["zfs-import-tank.service"];
  };

  users.users = {
    sonarr.extraGroups = ["media"];
    radarr.extraGroups = ["media"];
    jellyfin.extraGroups = ["media"];
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr";
    environment = {
      LOG_LEVEL = "info";
      TZ = "America/Los_Angeles";
    };
    ports = ["${toString ports.flaresolverr}:${toString ports.flaresolverr}"];
    extraOptions = [];
  };

  # Restrict service ports to Tailscale interface only — not reachable from local network
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    ports.jellyfin
    ports.sonarr
    ports.radarr
    ports.prowlarr
    ports.qbittorrent
    ports.flaresolverr
  ];
}
