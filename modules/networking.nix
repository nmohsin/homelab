{ ... }:

{
  networking = {
    hostName = "moyfii";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
}
