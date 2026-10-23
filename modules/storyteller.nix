{ config, ports, ... }:
{
  sops.secrets.storyteller_secret_key = {
    sopsFile = ../secrets/storyteller.yaml;
    mode = "0444";
  };

  virtualisation.oci-containers.containers.storyteller = {
    image = "registry.gitlab.com/storyteller-platform/storyteller:latest";
    environment = {
      STORYTELLER_SECRET_KEY_FILE = "/run/secrets/storyteller_secret_key";
    };
    volumes = [
      "/var/lib/storyteller:/data"
      "${config.sops.secrets.storyteller_secret_key.path}:/run/secrets/storyteller_secret_key:ro"
    ];
    extraOptions = [ "--network=host" ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.storyteller ];

  systemd.tmpfiles.rules = [
    "d /var/lib/storyteller 0755 root root -"
  ];
}
