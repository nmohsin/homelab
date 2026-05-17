---
name: nix-add-service
description: Scaffold a new service in the homelab NixOS config. Adds port to flake.nix, creates/extends module, opens firewall on tailscale0, adds Homepage widget, updates README.md and CLAUDE.md. Use when adding a new service.
argument-hint: "[service-name]"
arguments: service
---

## Checklist

Follow every step. Do not skip docs or Homepage.

### 1. Add port to `flake.nix`

Add an entry to `specialArgs.ports` in `flake.nix`. Use the service's default port. Example:

```nix
ports = {
  # ... existing ports ...
  $service = <port>;
};
```

### 2. Create or extend a module in `modules/`

Ask the user: Docker container or native NixOS service?

**Docker** — use `virtualisation.oci-containers.containers`:

```nix
{ ports, ... }:
{
  virtualisation.oci-containers.containers.$service = {
    image = "<image>";
    volumes = [ "/var/lib/$service:/data" ];
    ports = [ "${toString ports.$service}:${toString ports.$service}" ];
    extraOptions = [ ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.$service ];
}
```

IMPORTANT: Never use `--restart` flags — NixOS manages restarts via systemd.

**Native NixOS** — enable the service module, add systemd hardening:

```nix
{ ports, ... }:
{
  services.$service.enable = true;

  systemd.services.$service = {
    serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/$service" ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ports.$service ];
}
```

If the service needs ZFS data, add `after = [ "zfs-import-tank.service" ];`.

### 3. Import the module (if new file)

If you created a new module file, add it to the imports in `configuration.nix`.

### 4. Add Homepage widget in `modules/homepage.nix`

Add an entry to the appropriate category in `servicesYaml`. Follow the existing pattern exactly:

```yaml
- ServiceName:
    icon: servicename.png
    href: http://${host}:${toString ports.$service}
    description: Short description
    ping: http://${host}:${toString ports.$service}
```

### 5. Update `README.md`

- Add the service to the **network topology** ASCII diagram
- Add a row to the **Port reference** table (sorted alphabetically)
- If the service has any operational notes, add them under Procedures

### 6. Update `CLAUDE.md`

- Add the service to the appropriate bullet under **## Services** (Native NixOS or Docker)
- Add any gotchas discovered during setup under the relevant **## Gotchas** section

### 7. Remind about Uptime Kuma

Tell the user: "Add a monitor in Uptime Kuma (`http://moyfii.tail083295.ts.net:3001`) for the new service. Use the Tailscale FQDN as the URL. If the service returns non-200 at root, use a `/ping` or `/health` endpoint."

### 8. Harden (native services only)

If the new service is a native NixOS service (not Docker), invoke `/nix-harden` on the module to review and apply systemd hardening.

### 9. Format

Run `nixfmt` on all changed `.nix` files.
