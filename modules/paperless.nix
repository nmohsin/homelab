{
  ports,
  ...
}:
{
  services.paperless = {
    enable = true;
    port = ports.paperless;
    address = "0.0.0.0";
    dataDir = "/data/paperless/data";
    consumptionDir = "/data/paperless/consume";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_TIME_ZONE = "America/Los_Angeles";
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_CONSUMER_POLLING = 30;
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
    };
  };

  systemd.services = {
    paperless-scheduler.after = [ "zfs-import-tank.service" ];
    paperless-consumer.after = [ "zfs-import-tank.service" ];
    paperless-web.after = [ "zfs-import-tank.service" ];
    paperless-task-queue.after = [ "zfs-import-tank.service" ];
  };

  system.activationScripts.paperless-dirs.text = ''
    mkdir -p /data/paperless/{data,consume}
    chown -R paperless:paperless /data/paperless
    chmod 775 /data/paperless/consume
  '';

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.paperless ];
}
