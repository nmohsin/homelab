# Homelab NixOS Config

## Key facts

- Hostname: moyfii
- NixOS 25.11, flakes enabled
- ZFS RAIDZ1 pool "tank" on 4x WD Red SSDs, mounted at /data
- LTS kernel required (not latest) due to ZFS compatibility
- Two users: nadeem (wheel/docker, SSH key), fiifii (wheel)
- Remote: git@github.com:nmohsin/homelab.git
- Tailscale SSH enabled — accessible as `moyfii` from any Tailnet device

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
