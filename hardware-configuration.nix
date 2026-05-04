{ config, lib, pkgs, modulesPath, ... }:

{
  # TODO: Generate with `nixos-generate-config` on the target machine
  # and replace this file with the output.

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
