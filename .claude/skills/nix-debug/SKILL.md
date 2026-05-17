---
name: nix-debug
description: Debug the homelab server (moyfii) via SSH. Runs diagnostic commands remotely to investigate service issues, check logs, inspect containers, and verify system state. Use when troubleshooting any homelab problem.
allowed-tools: Bash(ssh moyfii *)
---

## Instructions

You can run commands on moyfii via `ssh moyfii <command>`.

### Commands you can run directly

These do NOT require sudo:

```bash
# Service status
ssh moyfii systemctl status <service>
ssh moyfii systemctl list-units --failed

# Logs (most services)
ssh moyfii journalctl -u <service> --no-pager -n 50
ssh moyfii journalctl -u <service> --no-pager --since '1 hour ago'

# Docker
ssh moyfii docker ps
ssh moyfii docker ps -a
ssh moyfii docker logs <container> --tail 50
ssh moyfii docker inspect <container>

# Network
ssh moyfii ss -tlnp
ssh moyfii curl -s http://localhost:<port>

# Disk / ZFS (read-only)
ssh moyfii df -h
ssh moyfii zfs list
ssh moyfii zfs list -t snapshot

# General
ssh moyfii uptime
ssh moyfii free -h
ssh moyfii uname -r
```

### Service names reference

| Service | systemd unit | Docker container |
|---------|-------------|-----------------|
| Jellyfin | `jellyfin.service` | — |
| Sonarr | `sonarr.service` | — |
| Radarr | `radarr.service` | — |
| Prowlarr | `prowlarr.service` | — |
| qBittorrent | `docker-qbittorrent.service` | `qbittorrent` |
| Gluetun | `docker-gluetun.service` | `gluetun` |
| FlareSolverr | `docker-flaresolverr.service` | `flaresolverr` |
| Homepage | `docker-homepage.service` | `homepage` |
| Uptime Kuma | `docker-uptime-kuma.service` | `uptime-kuma` |
| Tailscale | `tailscaled.service` | — |

### Commands that need sudo

These require sudo and you CANNOT run them via SSH. Instead, ask the user to run the command in their own terminal and paste the output:

- `sudo journalctl -u <service>` (when permission denied on specific units)
- `sudo zpool status`
- `sudo zpool scrub tank`
- `sudo systemctl restart <service>`
- `sudo systemctl stop/start <service>`
- `sudo docker pull <image>`
- `sudo nixos-rebuild switch --flake '.#homelab'`
- `sudo nix-collect-garbage -d`

Format your request like:
> Can you run this on moyfii and paste the output?
> ```
> sudo zpool status
> ```

### Debugging workflow

1. Start with `systemctl status` and recent logs for the affected service
2. For Docker services, also check `docker ps -a` (container might be restarting) and `docker logs`
3. Check if dependent services are healthy (e.g., Gluetun before qBittorrent)
4. Check disk space and ZFS pool health if I/O related
5. Check network connectivity with `curl` to the service port
