{
  description = "Homelab NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        ports = {
          jellyfin    = 8096;
          sonarr      = 8989;
          radarr      = 7878;
          prowlarr    = 9696;
          qbittorrent = 8080;
          flaresolverr = 8191;
          homepage    = 3000;
        };
      };
      modules = [
        sops-nix.nixosModules.sops
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
