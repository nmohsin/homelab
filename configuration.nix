{ config, pkgs, ... }:

{
  imports = [
    ./modules/users.nix
    ./modules/ssh.nix
    ./modules/packages.nix
    ./modules/networking.nix
  ];

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.git.enable = true;

  environment.variables = {
    EDITOR = "vim";
  };
}
