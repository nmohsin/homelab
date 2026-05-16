_: {
  # Decrypt secrets using the machine's SSH host key — no user interaction needed at boot
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.protonvpn_conf = {
    sopsFile = ../secrets/protonvpn.conf;
    format = "binary";
    path = "/etc/secrets/protonvpn.conf";
    mode = "0600";
  };
}
