{ ports, ... }:
{
  virtualisation.oci-containers.containers.uptime-kuma = {
    image = "louislam/uptime-kuma:1";
    volumes = [
      "/var/lib/uptime-kuma:/app/data"
    ];
    ports = [ "${toString ports.uptimekuma}:3001" ];
    extraOptions = [ ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.uptimekuma ];
}
