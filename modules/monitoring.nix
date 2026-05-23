{
  config,
  ports,
  ...
}:
{
  services.prometheus = {
    enable = true;
    port = ports.prometheus;

    exporters = {
      node = {
        enable = true;
        port = ports.nodeExporter;
        enabledCollectors = [
          "zfs"
          "systemd"
        ];
      };
      exportarr-sonarr = {
        enable = true;
        port = ports.exportarrSonarr;
        url = "http://localhost:${toString ports.sonarr}";
        apiKeyFile = config.sops.secrets.sonarr_api_key.path;
      };
      exportarr-radarr = {
        enable = true;
        port = ports.exportarrRadarr;
        url = "http://localhost:${toString ports.radarr}";
        apiKeyFile = config.sops.secrets.radarr_api_key.path;
      };
      exportarr-prowlarr = {
        enable = true;
        port = ports.exportarrProwlarr;
        url = "http://localhost:${toString ports.prowlarr}";
        apiKeyFile = config.sops.secrets.prowlarr_api_key.path;
      };
      exportarr-bazarr = {
        enable = true;
        port = ports.exportarrBazarr;
        url = "http://localhost:${toString ports.bazarr}";
        apiKeyFile = config.sops.secrets.bazarr_api_key.path;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "localhost:${toString ports.nodeExporter}" ]; } ];
      }
      {
        job_name = "sonarr";
        static_configs = [ { targets = [ "localhost:${toString ports.exportarrSonarr}" ]; } ];
      }
      {
        job_name = "radarr";
        static_configs = [ { targets = [ "localhost:${toString ports.exportarrRadarr}" ]; } ];
      }
      {
        job_name = "prowlarr";
        static_configs = [ { targets = [ "localhost:${toString ports.exportarrProwlarr}" ]; } ];
      }
      {
        job_name = "bazarr";
        static_configs = [ { targets = [ "localhost:${toString ports.exportarrBazarr}" ]; } ];
      }
      {
        job_name = "cadvisor";
        static_configs = [ { targets = [ "localhost:${toString ports.cadvisor}" ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = ports.grafana;
      domain = "moyfii.tail083295.ts.net";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString ports.prometheus}";
          isDefault = true;
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    uptime-kuma = {
      image = "louislam/uptime-kuma:1";
      volumes = [ "/var/lib/uptime-kuma:/app/data" ];
      extraOptions = [ "--network=host" ];
    };
    cadvisor = {
      image = "gcr.io/cadvisor/cadvisor:v0.49.2";
      volumes = [
        "/:/rootfs:ro"
        "/var/run:/var/run:ro"
        "/sys:/sys:ro"
        "/var/lib/docker:/var/lib/docker:ro"
        "/dev/disk/:/dev/disk:ro"
      ];
      ports = [ "${toString ports.cadvisor}:8080" ];
      extraOptions = [
        "--privileged"
        "--device=/dev/kmsg"
      ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    ports.uptimekuma
    ports.prometheus
    ports.grafana
  ];
}
