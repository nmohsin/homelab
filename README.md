# Homelab

NixOS configuration for the family homelab server (hostname: `moyfii`).

## Hardware

- CPU: AMD (with ECC memory)
- Boot: 466GB NVMe (Kingston) — EFI, root, swap
- Storage: 4x 1.8TB WD Red SA500 SSDs — ZFS RAIDZ1 pool (`tank`), mounted at `/data`

## Architecture

### Network topology

```
┌─────────────────────────────────────────────────────────────┐
│  Tailscale Network (tailscale0)                             │
│                                                             │
│   Mac / Phone ──────────► moyfii.tail083295.ts.net          │
│                               │                             │
│   ┌─ Media ─────────────────────────────────────────────┐   │
│   │  Jellyfin :8096  Sonarr :8989  Radarr :7878         │   │
│   │  Prowlarr :9696  Bazarr :6767  Jellyseerr :5055     │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─ Downloads ─────────────────────────────────────────┐   │
│   │  FlareSolverr :8191                                 │   │
│   │  ┌─ Gluetun (ProtonVPN WireGuard) ──────────────┐   │   │
│   │  │  qBittorrent :8080                           │   │   │
│   │  └──────────────────────────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─ Documents ─────────────────────────────────────────┐   │
│   │  Paperless-ngx :28981    Nextcloud :8085            │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─ Monitoring ────────────────────────────────────────┐   │
│   │  Homepage :3000    Uptime Kuma :3001                │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   Local network can only reach SSH (port 22).               │
│   All service ports are bound to tailscale0 only.           │
│   qBittorrent traffic exits through Gluetun's VPN tunnel.   │
└─────────────────────────────────────────────────────────────┘
```

### Design decisions

- **Tailscale-only service access** — exposing services to the LAN would require firewall rules, port forwarding, and trusting every device on the network. Instead, all service ports are bound to `tailscale0` only, so they're reachable from any Tailnet device (Mac, phone, etc.) but completely invisible to the LAN. Tailscale handles authentication, so no additional auth layer is needed for internal services.
- **Media group (GID 994)** — Sonarr, Radarr, Bazarr, Jellyfin, and qBittorrent all need read/write access to the same directories under `/data`. A shared `media` group is the simplest way to express this without running any service as root or managing complex ACLs.
- **Docker via `virtualisation.oci-containers`** — running `docker-compose` separately would mean managing a parallel lifecycle outside NixOS. Using `virtualisation.oci-containers` instead keeps containers part of the declarative system config: NixOS generates a systemd unit per container, handling restarts and dependencies consistently with native services. Do not use Docker's `--restart` flags (they conflict with systemd).
- **Centralized port numbers** — with many services, port assignments scattered across modules are easy to collide and hard to audit. Defining all ports once in `flake.nix` as `specialArgs.ports` gives a single place to check what's in use and change a port without hunting through multiple files.
- **Native vs Docker** — native NixOS modules (Jellyfin, Sonarr, Radarr, Prowlarr, Bazarr, Paperless-ngx, Nextcloud) are preferred because NixOS manages their users, systemd hardening, and config files properly. Docker is used only where no native module exists or where the container approach is materially simpler (qBittorrent, FlareSolverr, Recyclarr, Homepage, Uptime Kuma).
- **Recyclarr** — keeping Sonarr and Radarr quality profiles aligned with the TRaSH Guide manually would be a recurring chore prone to drift. Recyclarr automates this by syncing quality profiles and custom formats every 6 hours. Config is inline in `arr.nix`; API keys are in `secrets/arr-api-keys.yaml` (sops-encrypted).
- **qBittorrent through Gluetun** — routing torrent traffic through a VPN prevents the ISP from seeing it, avoiding throttling and DMCA notices. qBittorrent uses `--network=container:gluetun` so all its traffic exits through Gluetun's ProtonVPN WireGuard tunnel; it cannot accidentally bypass the VPN. The WebUI port (8080) is exposed through Gluetun's port mappings.
- **Secrets via sops-nix** — secrets need to live somewhere, and keeping them outside the repo means manual copying to the server on every change. sops-nix allows secrets to be encrypted with age keys and committed to the repo safely. At boot, sops-nix decrypts them using the machine's SSH host key — no manual steps needed after a rebuild.
- **ZFS snapshot policy** — daily (7), weekly (4), monthly (3). Frequent (15-min) and hourly snapshots are disabled because the media workload is write-once: files are large, rarely modified after import, and not worth the storage cost of high-frequency snapshots.
- **Gluetun starts after Tailscale** — if the WireGuard tunnel comes up first, it can claim routes that Tailscale needs, preventing Tailscale from connecting at boot. Ordering Gluetun after `tailscaled` avoids this conflict.

### Port reference

| Service       | Port | Type           | Module         |
|---------------|------|----------------|----------------|
| Homepage      | 3000 | Docker         | `homepage.nix` |
| Jellyfin      | 8096 | Native NixOS   | `arr.nix`      |
| Jellyseerr    | 5055 | Native NixOS   | `arr.nix`      |
| qBittorrent   | 8080 | Docker/Gluetun | `vpn.nix`      |
| Radarr        | 7878 | Native NixOS   | `arr.nix`      |
| Sonarr        | 8989 | Native NixOS   | `arr.nix`      |
| Prowlarr      | 9696 | Native NixOS   | `arr.nix`      |
| Bazarr        | 6767 | Native NixOS   | `arr.nix`      |
| FlareSolverr  | 8191 | Docker         | `arr.nix`      |
| Nextcloud     | 8085 | Native NixOS   | `nextcloud.nix`  |
| Paperless-ngx | 28981| Native NixOS   | `paperless.nix`  |
| Uptime Kuma   | 3001 | Docker         | `monitoring.nix` |

Port numbers are defined in `flake.nix` as `specialArgs.ports`.

## File structure

```
flake.nix                   # Entry point: pins nixpkgs 25.11, sops-nix input, defines specialArgs (ports)
flake.lock                  # Locked dependency versions (auto-generated by nix flake update)
configuration.nix           # Top-level config: boot, locale, nix GC, shell aliases, imports all modules
hardware-configuration.nix  # Machine-generated by nixos-generate-config — do not hand-edit
.sops.yaml                  # SOPS encryption rules: age key recipients (Mac + host SSH key)
.justfile                   # Task runner: deploy, fmt, lint, gc, sops commands (run 'just' to list)
secrets/
  protonvpn.conf            # Encrypted ProtonVPN WireGuard config (sops-encrypted, binary format)
  arr-api-keys.yaml         # Encrypted Sonarr/Radarr API keys for Recyclarr (sops-encrypted, yaml format)
docs/
  protonvpn.md              # Runbook: updating the ProtonVPN WireGuard config
  adding-a-service.md       # Runbook: adding a new service to the homelab
  adding-a-secret.md        # Runbook: adding a new sops-encrypted secret
  bootstrap.md              # Runbook: fresh NixOS install from scratch
modules/
  users.nix                 # User accounts (nadeem, fiifii), media group (GID 994)
  ssh.nix                   # OpenSSH: key-only auth, no root login, no interactive auth
  packages.nix              # System packages (cli tools, networking, etc.), zsh + oh-my-zsh config
  networking.nix            # Hostname (moyfii), firewall base (SSH on all interfaces)
  zfs.nix                   # ZFS pool "tank", auto-snapshots, ZED health alerts to ntfy.sh
  tailscale.nix             # Tailscale VPN client, UDP port 41641, Tailscale SSH
  secrets.nix               # sops-nix config: decrypts protonvpn.conf at boot via SSH host key
  vpn.nix                   # Docker: Gluetun (ProtonVPN WireGuard) + qBittorrent (uses Gluetun network)
  arr.nix                   # Sonarr, Radarr, Prowlarr, Bazarr, Jellyfin (native NixOS), FlareSolverr + Recyclarr (Docker)
  homepage.nix              # Homepage dashboard (Docker), config written by NixOS activation script
  paperless.nix             # Paperless-ngx (native NixOS) — document management with OCR
  nextcloud.nix             # Nextcloud (native NixOS) — file sync with PostgreSQL + Redis
  monitoring.nix            # Uptime Kuma (Docker) — service uptime monitoring
  auto-update.nix           # Daily auto-upgrade from GitHub flake (no auto-reboot)
```

## Procedures

### Applying changes

Edit configs, then on the server:

```bash
cd ~/homelab
git pull
just deploy
```

Or without just: `rebuild` (shell alias) or `sudo nixos-rebuild switch --flake '.#homelab'`.

### Common operations

All common operations are in `.justfile`. Run `just` to list them:

| Command | What it does |
|---------|-------------|
| `just deploy` | Rebuild and switch |
| `just fmt` | Format all .nix files (nixfmt) |
| `just lint` | Lint all .nix files (statix) |
| `just up` | Update flake.lock (nixpkgs, sops-nix) |
| `just gc` | Garbage collect old generations |
| `just repair` | Verify and repair the nix store |
| `just sops-edit` | Edit the encrypted ProtonVPN config |
| `just sops-rotate` | Rotate all secret encryption keys |
| `just sops-update` | Update encryption keys in all secrets |

### Rollback

```bash
sudo nixos-rebuild switch --rollback
```

### ZFS commands

```bash
zpool status          # Pool health
zpool list            # Capacity overview
zfs list              # Datasets and usage
zfs list -t snapshot  # List all snapshots
```

### SSH access

- **Local network**: `ssh nadeem@<ip_address>`
- **Anywhere via Tailscale**: `ssh nadeem@moyfii` (from any device on the Tailnet)

After first rebuild with Tailscale, authenticate once: `sudo tailscale up --ssh`

### Updating nixpkgs

```bash
nix flake update           # updates flake.lock with latest nixpkgs
rebuild                    # apply the update
```

If the rebuild fails (usually ZFS kernel module mismatch), roll back:

```bash
git checkout flake.lock
rebuild
```

### Monitoring

**Uptime Kuma** — available at `http://moyfii.tail083295.ts.net:3001`. Monitors are configured in the web UI (not Nix). Data persists in `/var/lib/uptime-kuma`.

Monitor URLs use the Tailscale FQDN (`http://moyfii.tail083295.ts.net:<port>`). Sonarr, Radarr, and Prowlarr should use the `/ping` endpoint — their root URL returns non-200.

**ZFS health (ZED)** — pool events are sent to [ntfy.sh](https://ntfy.sh) topic `homelab-moyfii-zfs`. Subscribe from any device:

```bash
# Terminal
curl -s https://ntfy.sh/homelab-moyfii-zfs/json

# Phone: install ntfy app, subscribe to homelab-moyfii-zfs
```

**Note:** this topic is public — anyone who knows the name can subscribe. To change it, edit `ntfyTopic` in `modules/zfs.nix` and rebuild.

### Homepage dashboard

Available at `http://moyfii:3000` (or `http://moyfii.tail083295.ts.net:3000`) from any Tailnet device.

Config is managed in `modules/homepage.nix` — the activation script writes config files to `/var/lib/homepage/` on every rebuild. Edits made through the Homepage UI will not persist across rebuilds.

### Secrets management

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption. Two keys are configured in `.sops.yaml`:

- **Personal age key** — for encrypting/editing secrets on your Mac. Lives at `~/.config/sops/age/keys.txt` (backed up in Bitwarden).
- **Homelab SSH host key** — for decrypting secrets at boot on the server. Derived automatically from `/etc/ssh/ssh_host_ed25519_key`.

No manual steps are needed on the server after a rebuild — sops-nix handles decryption automatically.

## Runbooks

Step-by-step guides for common tasks live in `docs/`:

- [Terminology](docs/terminology.md)
- [Updating the ProtonVPN config](docs/protonvpn.md)
- [Adding a new service](docs/adding-a-service.md)
- [Adding a new encrypted secret](docs/adding-a-secret.md)
- [Bootstrap (fresh NixOS install)](docs/bootstrap.md)

## External dependencies

| Dependency | Purpose | Where configured |
|-----------|---------|-----------------|
| Tailscale account | VPN overlay for all service access | `modules/tailscale.nix`; one-time `tailscale up --ssh` |
| ProtonVPN account | WireGuard config for torrent VPN | `secrets/protonvpn.conf` (encrypted) |
| SOPS age key | Encrypt/decrypt secrets on Mac | `~/.config/sops/age/keys.txt`; backup in Bitwarden |
| ntfy.sh | ZFS health alerts | `modules/zfs.nix` (public topic — consider changing) |
