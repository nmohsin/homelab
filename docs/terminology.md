# Terminology

Common language used throughout this homelab's config and documentation.

## Infrastructure

**Tailscale** — a VPN overlay that connects all devices (Mac, phone, server) into a private "Tailnet". All homelab services are exposed only on the `tailscale0` interface, making them reachable from anywhere on the Tailnet but invisible to the LAN.

**Gluetun** — a Docker container that establishes a WireGuard tunnel to ProtonVPN. qBittorrent shares Gluetun's network namespace (`--network=container:gluetun`), so all torrent traffic exits through the VPN.

**sops-nix** — secret management for NixOS. Secrets (VPN config, API keys) are encrypted with age keys and stored in the repo. sops-nix decrypts them at boot using the server's SSH host key — no manual steps needed after a rebuild.

**ZFS** — the filesystem used for the data pool (`tank`, mounted at `/data`). Provides RAIDZ1 redundancy across four SSDs, plus automatic snapshotting. Requires the LTS kernel (not `_latest`) for module compatibility.

**Nix flakes** — the entry point for the entire config (`flake.nix`). Pins exact versions of nixpkgs and other inputs, and defines `specialArgs` (including port numbers) passed to all modules.

## Service Categories

These match the groups shown on the Homepage dashboard.

**Media** — services for finding, fetching, and playing back content.
- Sonarr (TV shows), Radarr (movies), Prowlarr (indexers), Bazarr (subtitles), Jellyfin (playback)

**Downloads** — services involved in acquiring files.
- qBittorrent (torrent client, routed through ProtonVPN via Gluetun), FlareSolverr (Cloudflare bypass for indexers)

**Documents** — services for personal file and document management.
- Paperless-ngx (document OCR and search), Nextcloud (file sync and sharing)

**Monitoring** — observability and the dashboard itself.
- Homepage (service dashboard), Uptime Kuma (uptime monitoring)

## NixOS Concepts

**Module** — a single `.nix` file in `modules/` that configures one concern (e.g. `arr.nix` for media services). All modules are imported by `configuration.nix`.

**specialArgs** — values defined in `flake.nix` and passed into every module. Port numbers live here, making `flake.nix` the single source of truth for port assignments.

**Native NixOS service** — a service run directly by NixOS using its built-in module (e.g. Sonarr, Jellyfin, Paperless-ngx, Nextcloud). NixOS manages users, systemd units, and config files.

**Docker / OCI container** — a service run as a container via `virtualisation.oci-containers`. NixOS generates a systemd unit per container. Used when no native NixOS module exists or the container approach is simpler (e.g. qBittorrent, Homepage, Uptime Kuma).

**Recyclarr** — a background container (no UI) that syncs TRaSH Guide quality profiles and custom formats into Sonarr and Radarr every 6 hours. Not shown on Homepage because it has no user-facing interface.

## Data Layout

**`/data`** — mount point for the ZFS pool `tank`. All persistent service data lives here.

**`/data/media`** — media files: `tv/` and `movies/` subdirectories. Written by Sonarr/Radarr, read by Jellyfin.

**`/data/downloads`** — landing zone for qBittorrent. Sonarr and Radarr monitor this directory and import completed downloads into `/data/media`.

**`media` group (GID 994)** — shared group for all services that need read/write access to media directories (Sonarr, Radarr, Bazarr, Jellyfin, qBittorrent container). Avoids running any service as root.

**`/data/paperless`, `/data/nextcloud`** — isolated data directories for document and file services respectively, both on ZFS for snapshot coverage.
