# Adding a New Service

1. Choose a port and add it to `specialArgs.ports` in `flake.nix`
2. Create or edit the appropriate module in `modules/`
   - For Docker: use `virtualisation.oci-containers.containers`, do **not** use `--restart` flags
   - For native NixOS: use the service's NixOS module
3. Open the port on Tailscale: add to `networking.firewall.interfaces.tailscale0.allowedTCPPorts` in the module
4. Add a service entry to the `servicesYaml` in `modules/homepage.nix`
5. Rebuild and test
6. Update README.md and CLAUDE.md
