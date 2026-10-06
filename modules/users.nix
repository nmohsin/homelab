{
  config,
  pkgs,
  ...
}:
{
  users = {
    users.nadeem = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCVa9SU6Uk6T9oOMQXyoaZ6pr5dUzTkS5N/YIKVm3VH abstractwhiz@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxg8lHFbGSp41z1ssJgZKrMcbMTgwkysJ0s+MH7CYAE nadeem@Nadeems-Mac-mini"
      ];
    };

    users.fiifii = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };

    groups.media.gid = 994;
  };

  security.sudo.wheelNeedsPassword = true;
}
