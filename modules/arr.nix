{ports, ...}: {
  services.prowlarr.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.jellyfin.enable = true;

  systemd.services.prowlarr.after = ["zfs-import-tank.service"];
  systemd.services.sonarr.after = ["zfs-import-tank.service"];
  systemd.services.radarr.after = ["zfs-import-tank.service"];
  systemd.services.jellyfin.after = ["zfs-import-tank.service"];

  users.users.sonarr.extraGroups = ["media"];
  users.users.radarr.extraGroups = ["media"];
  users.users.jellyfin.extraGroups = ["media"];

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
