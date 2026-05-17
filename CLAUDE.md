# Homelab NixOS Config

## Identity

- Hostname: moyfii
- NixOS 25.11, flakes enabled
- Remote: git@github.com:nmohsin/homelab.git
- Rebuild: `just deploy` (or `sudo nixos-rebuild switch --flake '.#homelab'`)

## Architecture

- Config is modular: one file per concern in `modules/`
- All service ports open only on `tailscale0` — unreachable from LAN, only via Tailnet
- Port numbers defined as `specialArgs.ports` in `flake.nix`, passed to modules
- Docker managed via `virtualisation.oci-containers` (systemd lifecycle, not docker-compose)
- Secrets via sops-nix — encrypted with age, decrypted at boot using SSH host key
- Formatter: nixfmt-tree (defined in flake.nix). Linter: statix. Both run automatically via pre-commit hook — do not run manually
- Native services have systemd hardening (ProtectSystem=strict, NoNewPrivileges, PrivateTmp, ProtectHome)

## Services

- **Native NixOS**: Sonarr, Radarr, Prowlarr, Bazarr, Jellyfin — all in `arr.nix`
- **Docker**: qBittorrent (`vpn.nix`), Gluetun (`vpn.nix`), FlareSolverr (`arr.nix`), Homepage (`homepage.nix`), Uptime Kuma (`monitoring.nix`)
- qBittorrent uses `--network=container:gluetun` — all traffic routes through ProtonVPN
- Homepage config written by NixOS activation script from `homepage.nix` — UI edits do not persist
- All service links in Homepage use Tailscale FQDN: `http://moyfii.tail083295.ts.net:PORT`
- Daily auto-upgrade from GitHub flake (07:00 ± 1h, no auto-reboot) — see `auto-update.nix`

## Users and permissions

- nadeem: wheel, docker, networkmanager, SSH key auth
- fiifii: wheel, networkmanager, password auth
- media group GID 994: sonarr, radarr, bazarr, jellyfin users + qBittorrent container (PGID=994)
- `/data/downloads`, `/data/media/tv`, `/data/media/movies`: owned `root:media`, mode 775, setgid

## Conventions

- Common operations are in `.justfile` — run `just` to list them
- One module per concern in `modules/`
- `hardware-configuration.nix` is machine-generated — never hand-edit
- System packages go in `modules/packages.nix`
- New service ports: add to `specialArgs.ports` in `flake.nix`, reference as `ports.<name>` in module
- New firewall openings: add to `networking.firewall.interfaces.tailscale0.allowedTCPPorts` in the relevant module
- Keep CLAUDE.md and README.md updated when system changes are made

## Gotchas: ZFS

- LTS kernel required (`pkgs.linuxPackages`, not `pkgs.linuxPackages_latest`) — ZFS modules must match running kernel
- Changing kernel packages requires a reboot (module mismatch otherwise)
- `boot.zfs.extraPools` fails harmlessly on rebuild if the pool doesn't exist yet
- `networking.hostId` in `modules/zfs.nix` is machine-specific — must match `head -c 8 /etc/machine-id`
- ZFS auto-snapshots: 7 daily, 4 weekly, 3 monthly (frequent/hourly disabled — media workload)

## Gotchas: VPN / ProtonVPN

- ProtonVPN WireGuard conf requires manual edits: (1) remove DNS line, (2) remove IPv6 from Address, (3) uncomment IPv6 endpoint
- `AllowedIPs` must exclude `100.64.0.0/10` (Tailscale CGNAT range) — including it breaks Tailscale
- Gluetun/WireGuard configured to start after `tailscaled` to avoid boot ordering conflicts
- On fresh setup, pull qBittorrent image before Gluetun starts — pulls fail through the VPN: `sudo systemctl stop docker-gluetun && sudo docker pull lscr.io/linuxserver/qbittorrent && sudo systemctl start docker-gluetun`

## Gotchas: Docker / Containers

- Never use `--restart=unless-stopped` with `virtualisation.oci-containers` — NixOS manages restarts via systemd; combining both prevents containers from starting
- qBittorrent downloads to `/downloads` inside container = `/data/downloads` on host

## Gotchas: Services

- Sonarr and Radarr need remote path mappings in their web UIs: host `localhost`, remote `/downloads`, local `/data/downloads`
- Homepage config at `/var/lib/homepage/` is overwritten on every rebuild — edit `modules/homepage.nix`, not the container filesystem

## Gotchas: Users / Auth

- User passwords are set imperatively with `passwd`, not in nix config
- Tailscale requires one-time `sudo tailscale up --ssh` after first rebuild

## Gotchas: Monitoring

- Uptime Kuma uses `--network=host` so it can reach all local services — monitor URLs use the Tailscale FQDN
- Uptime Kuma monitors are configured in its web UI, not in Nix — data persists in `/var/lib/uptime-kuma`
- Sonarr/Radarr/Prowlarr monitors should use the `/ping` endpoint (root URL returns non-200)
- ZED alerts go to ntfy.sh topic `homelab-moyfii-zfs` — this topic is public; change in `modules/zfs.nix` or self-host ntfy for privacy
