# Adding a New Encrypted Secret

1. Place the plaintext file in `secrets/`
2. Encrypt it: `sops --encrypt --in-place secrets/<filename>`
3. Add a `sops.secrets.<name>` entry in `modules/secrets.nix` with the path and permissions
4. Reference the decrypted path (`config.sops.secrets.<name>.path`) in the consuming module
5. Commit the encrypted file (never commit plaintext secrets)
