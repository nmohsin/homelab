{ pkgs, ... }:
{
  imports = [
    ./modules/users.nix
    ./modules/ssh.nix
    ./modules/packages.nix
    ./modules/networking.nix
    ./modules/zfs.nix
    ./modules/tailscale.nix
    ./modules/vpn.nix
    ./modules/arr.nix
    ./modules/secrets.nix
    ./modules/homepage.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages;
  };

  hardware.enableRedistributableFirmware = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  system.stateVersion = "25.11";

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.git.enable = true;

  environment = {
    variables.EDITOR = "vim";
    shellAliases.rebuild = "sudo nixos-rebuild switch --flake '/home/nadeem/homelab#homelab'";
  };
}
