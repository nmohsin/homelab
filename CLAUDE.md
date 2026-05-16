# Homelab NixOS Config

## Key facts

- Hostname: moyfii
- NixOS 25.11, flakes enabled
- ZFS RAIDZ1 pool "tank" on 4x WD Red SSDs, mounted at /data
- ZFS auto-snapshots enabled: 7 daily, 4 weekly, 3 monthly (frequent/hourly disabled — media workload)
- LTS kernel required (not latest) due to ZFS compatibility
- Two users: nadeem (wheel/docker, SSH key), fiifii (wheel)
- Remote: git@github.com:nmohsin/homelab.git
- Tailscale SSH enabled — accessible as `moyfii` from any Tailnet device
- ArrStack: Sonarr, Radarr, Prowlarr, Jellyfin (native NixOS), qBittorrent + Gluetun (Docker)
- ArrStack ports only open on `tailscale0` — unreachable from local network, only accessible via Tailnet
- Media group GID 994 — sonarr, radarr, jellyfin, and qBittorrent container all share it for directory access

## Conventions

- Config is modular: one file per concern in `modules/`
- `hardware-configuration.nix` is machine-generated — don't hand-edit
- System packages go in `modules/packages.nix`
- Rebuild command: `sudo nixos-rebuild switch --flake '.#homelab'` (quote the `#` for zsh)

## Gotchas

- ZFS kernel modules must match the running kernel — changing kernel packages requires a reboot
- `boot.zfs.extraPools` will fail on rebuild if the pool doesn't exist yet; this is harmless before pool creation
- `networking.hostId` in `modules/zfs.nix` is machine-specific — must match `head -c 8 /etc/machine-id`
- User passwords are set imperatively with `passwd`, not in the nix config
- Tailscale requires one-time `sudo tailscale up --ssh` after first rebuild to authenticate
- ProtonVPN conf at `/etc/secrets/protonvpn.conf` — the `DNS` line must be removed, and `AllowedIPs` must exclude `100.64.0.0/10` (Tailscale range). Both were causing Tailscale to break on startup
- WireGuard (protonvpn) is configured to start after `tailscaled` to avoid ordering conflicts on boot
- ProtonVPN conf requires IPv6 endpoint uncommented and IPv6 address removed from `Address` line — Gluetun doesn't support IPv6 interface addresses
- `/data/downloads`, `/data/media/tv`, `/data/media/movies` must be owned by `root:media` with permissions 775 and setgid bit — run after fresh setup: `sudo chown -R root:media /data/downloads /data/media/tv /data/media/movies && sudo chmod -R 775 /data/downloads /data/media/tv /data/media/movies && sudo chmod g+s /data/downloads /data/media/tv /data/media/movies`
- qBittorrent downloads to `/downloads` inside container = `/data/downloads` on host
- Sonarr and Radarr both need a remote path mapping set in their web UIs: host `localhost`, remote `/downloads`, local `/data/downloads`
- On a fresh setup, pull the qBittorrent image before starting Gluetun — otherwise the pull fails through the VPN: `sudo systemctl stop docker-gluetun && sudo docker pull lscr.io/linuxserver/qbittorrent && sudo systemctl start docker-gluetun`
