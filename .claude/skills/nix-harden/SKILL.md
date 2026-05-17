---
name: nix-harden
description: Review and apply systemd hardening to native NixOS services. Checks for missing sandboxing directives, validates write paths, and applies hardening. Only for native services, not Docker containers.
argument-hint: "[module-file]"
arguments: module
---

## Instructions

Read the module file specified by the user (default: `modules/arr.nix`). For each native NixOS service in the module, check and apply systemd hardening.

Does NOT apply to Docker containers (`virtualisation.oci-containers`) — those are sandboxed by the container runtime.

## Hardening checklist

For each `systemd.services.<name>.serviceConfig`, check for these directives:

### Always apply (baseline)

| Directive | Value | Purpose |
|-----------|-------|---------|
| `NoNewPrivileges` | `true` | Prevent privilege escalation |
| `PrivateTmp` | `true` | Isolate /tmp |
| `ProtectHome` | `true` | Hide /home |
| `ProtectSystem` | `"strict"` | Read-only filesystem except explicit paths |

### Apply when possible (evaluate per service)

| Directive | Value | Notes |
|-----------|-------|-------|
| `ProtectKernelTunables` | `true` | Safe unless service tunes sysctl |
| `ProtectControlGroups` | `true` | Safe unless service manages cgroups |
| `ProtectKernelModules` | `true` | Safe unless service loads modules |
| `RestrictSUIDSGID` | `true` | Prevents setuid/setgid binaries |
| `MemoryDenyWriteExecute` | `true` | Blocks JIT; may break some services |
| `LockPersonality` | `true` | Prevents changing execution domain |
| `RestrictRealtime` | `true` | Safe for most services |

### Path access (critical — get this right)

| Directive | When to use |
|-----------|------------|
| `ReadWritePaths` | Service's state dir (e.g., `/var/lib/sonarr`) AND any data dirs it writes to |
| `ReadOnlyPaths` | Data dirs the service only reads (e.g., Jellyfin reading `/data/media`) |
| `StateDirectory` | Alternative to ReadWritePaths for `/var/lib/<name>` — creates the dir automatically |

**IMPORTANT**: If `ProtectSystem = "strict"` is set, the service CANNOT write anywhere except paths in `ReadWritePaths` or `StateDirectory`. Forgetting a write path breaks the service silently. Check:
- Where does the service store its database/config? (usually `/var/lib/<name>`)
- Does it download files? (e.g., Sonarr writes to `/data/downloads` and `/data/media/tv`)
- Does it use a cache dir? (e.g., Jellyfin uses `/var/cache/jellyfin`)

### ZFS dependency

If the service reads/writes from `/data` (ZFS pool `tank`), add:
```nix
after = [ "zfs-import-tank.service" ];
```

## Existing pattern

Reference `modules/arr.nix` for the established hardening pattern in this repo. Match that style.

## Output

For each service, report:
1. Which directives are already applied
2. Which directives are missing and recommended
3. Any write paths that may be missing
4. Apply the changes after confirming with the user
