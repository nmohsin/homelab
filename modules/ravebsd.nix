{ ports, ... }:
{
  virtualisation.oci-containers.containers.ravebsd = {
    image = "ghcr.io/idleendeavor/ravebsd:latest";
    environment = {
      PORT = toString ports.ravebsd;
    };
    volumes = [
      "/var/lib/ravebsd:/data"
      "/data/media/books:/books"
      "/data/media/audiobooks:/audiobooks"
      "/data/downloads:/downloads"
    ];
    extraOptions = [
      "--network=host"
      "--user=1000:994"
      "--shm-size=512m"
      "--security-opt=seccomp=${./files/seccomp-chromium.json}"
    ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.ravebsd ];

  systemd.tmpfiles.rules = [
    "d /var/lib/ravebsd 0755 nadeem media -"
  ];
}
