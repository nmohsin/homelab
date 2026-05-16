_: {
  system.autoUpgrade = {
    enable = true;
    flake = "github:nmohsin/homelab#homelab";
    dates = "07:00";
    randomizedDelaySec = "1h";
    allowReboot = false;
  };
}
