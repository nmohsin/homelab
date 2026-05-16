{ ports, ... }:
{
  virtualisation.oci-containers.containers.uptime-kuma = {
    image = "louislam/uptime-kuma:1";
    volumes = [
      "/var/lib/uptime-kuma:/app/data"
    ];
    extraOptions = [ "--network=host" ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.uptimekuma ];
}
