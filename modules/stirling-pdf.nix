{ ports, ... }:
{
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = toString ports.stirlingPdf;
    };
  };

  systemd.services = {
    stirling-pdf.serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.stirlingPdf ];
}
