{ config, pkgs, ... }:

{
  networking = {
    hostName = "homelab";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
}
