{ config, pkgs, ... }:

{
  users.users.nadeem = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCVa9SU6Uk6T9oOMQXyoaZ6pr5dUzTkS5N/YIKVm3VH abstractwhiz@gmail.com"
    ];
  };

  users.users.fiifii = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.sudo.wheelNeedsPassword = true;
}
