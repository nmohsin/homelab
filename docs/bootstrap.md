# Bootstrap (Fresh NixOS Install)

1. Install NixOS with the default config
2. Set a minimal `/etc/nixos/configuration.nix` with openssh, git, and your SSH key
3. `sudo nixos-rebuild switch`
4. SSH in and clone this repo to `~/homelab`
5. Copy `/etc/nixos/hardware-configuration.nix` into the repo root
6. Set `networking.hostId` in `modules/zfs.nix`:
   ```bash
   head -c 8 /etc/machine-id
   ```
7. `sudo nixos-rebuild switch --flake '.#homelab'`
8. Create the ZFS pool:
   ```bash
   sudo zpool create -o ashift=12 tank raidz1 /dev/disk/by-id/<disk1> <disk2> <disk3> <disk4>
   sudo zfs set mountpoint=/data tank
   ```
9. Create media directories with correct permissions:
   ```bash
   sudo mkdir -p /data/downloads /data/media/tv /data/media/movies /data/qbittorrent/config
   sudo chown -R root:media /data/downloads /data/media/tv /data/media/movies
   sudo chmod -R 775 /data/downloads /data/media/tv /data/media/movies
   sudo chmod g+s /data/downloads /data/media/tv /data/media/movies
   ```
10. Authenticate Tailscale:
    ```bash
    sudo tailscale up --ssh
    ```
11. Pull the qBittorrent Docker image **before** Gluetun starts (pulls fail through the VPN):
    ```bash
    sudo systemctl stop docker-gluetun
    sudo docker pull lscr.io/linuxserver/qbittorrent
    sudo systemctl start docker-gluetun
    ```
12. Set user passwords:
    ```bash
    sudo passwd nadeem
    sudo passwd fiifii
    ```
13. Configure Sonarr and Radarr remote path mappings in their web UIs:
    - Settings > Download Clients > Remote Path Mappings
    - Host: `localhost`, Remote: `/downloads`, Local: `/data/downloads`
14. Add indexers in Prowlarr and sync to Sonarr/Radarr
15. Rebuild once more to confirm everything starts cleanly: `rebuild`
