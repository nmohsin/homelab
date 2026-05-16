# Updating the ProtonVPN Config

When you download a new WireGuard config from ProtonVPN, apply these edits first:

1. **Remove the `DNS` line** entirely (breaks Tailscale DNS)
2. **Remove the IPv6 address** from the `Address` line (keep only IPv4 — Gluetun doesn't support IPv6 interface addresses)
3. **Uncomment the IPv6 endpoint** (needed for connectivity)
4. **Ensure `AllowedIPs` excludes `100.64.0.0/10`** (Tailscale CGNAT range — including it breaks Tailscale)

Then encrypt and deploy from your Mac:

```bash
# Copy edited config into the repo
cp /path/to/edited/protonvpn.conf secrets/protonvpn.conf
sops --encrypt --in-place secrets/protonvpn.conf
git add secrets/protonvpn.conf
git commit -m "Update encrypted ProtonVPN config"
git push
```

Then on the homelab:

```bash
git pull
rebuild
```
