{ config, pkgs, ... }:

{
  networking.wg-quick.interfaces.protonvpn = {
    configFile = "/etc/secrets/protonvpn.conf";
    autostart = true;
  };
}
