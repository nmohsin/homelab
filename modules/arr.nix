{
  config,
  ports,
  pkgs,
  ...
}:
let
  recyclarrConfig = pkgs.writeText "recyclarr.yml" ''
    sonarr:
      tv:
        base_url: !secret sonarr_url
        api_key: !secret sonarr_api_key
        quality_definition:
          type: series
        quality_profiles:
          - trash_id: 72dae194fc92bf828f32cde7744e51a1
            reset_unmatched_scores:
              enabled: true

    radarr:
      movies:
        base_url: !secret radarr_url
        api_key: !secret radarr_api_key
        quality_definition:
          type: movie
        quality_profiles:
          - trash_id: d1d67249d3890e49bc12e275d989a7e9
            reset_unmatched_scores:
              enabled: true
  '';
in
{
  sops.secrets.sonarr_api_key = {
    sopsFile = ../secrets/arr-api-keys.yaml;
    owner = "root";
  };
  sops.secrets.radarr_api_key = {
    sopsFile = ../secrets/arr-api-keys.yaml;
    owner = "root";
  };

  services = {
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    jellyfin.enable = true;
    bazarr.enable = true;
  };

  systemd.services = {
    prowlarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/prowlarr" ];
      };
    };
    sonarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        UMask = "0002";
        ReadWritePaths = [
          "/var/lib/sonarr"
          "/data/downloads"
          "/data/media/tv"
        ];
      };
    };
    radarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        UMask = "0002";
        ReadWritePaths = [
          "/var/lib/radarr"
          "/data/downloads"
          "/data/media/movies"
        ];
      };
    };
    jellyfin = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
        ];
        ReadOnlyPaths = [ "/data/media" ];
      };
    };
    bazarr = {
      after = [ "zfs-import-tank.service" ];
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        UMask = "0002";
        ReadWritePaths = [
          "/var/lib/bazarr"
          "/data/media/tv"
          "/data/media/movies"
        ];
      };
    };
  };

  users.users = {
    sonarr.extraGroups = [ "media" ];
    radarr.extraGroups = [ "media" ];
    jellyfin.extraGroups = [ "media" ];
    bazarr.extraGroups = [ "media" ];
  };

  system.activationScripts.recyclarr-config = {
    deps = [ "setupSecrets" ];
    text = ''
      mkdir -p /var/lib/recyclarr
      cp ${recyclarrConfig} /var/lib/recyclarr/recyclarr.yml
      cat > /var/lib/recyclarr/secrets.yml <<SECRETS
      sonarr_url: http://localhost:${toString ports.sonarr}
      sonarr_api_key: $(cat ${config.sops.secrets.sonarr_api_key.path})
      radarr_url: http://localhost:${toString ports.radarr}
      radarr_api_key: $(cat ${config.sops.secrets.radarr_api_key.path})
      SECRETS
      chown -R 1000:1000 /var/lib/recyclarr
    '';
  };

  virtualisation.oci-containers.containers.recyclarr = {
    image = "ghcr.io/recyclarr/recyclarr:8";
    volumes = [ "/var/lib/recyclarr:/config" ];
    environment = {
      CRON_SCHEDULE = "0 */6 * * *";
      TZ = "America/Los_Angeles";
    };
    extraOptions = [ "--network=host" ];
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr";
    environment = {
      LOG_LEVEL = "info";
      TZ = "America/Los_Angeles";
    };
    ports = [ "${toString ports.flaresolverr}:${toString ports.flaresolverr}" ];
    extraOptions = [ ];
  };

  # Restrict service ports to Tailscale interface only — not reachable from local network
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    ports.jellyfin
    ports.sonarr
    ports.radarr
    ports.prowlarr
    ports.qbittorrent
    ports.bazarr
    ports.flaresolverr
  ];
}
