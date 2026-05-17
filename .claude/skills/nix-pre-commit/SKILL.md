---
name: nix-pre-commit
description: Run nixfmt and statix on all .nix files, and check that README.md/CLAUDE.md are updated if modules changed. Use before committing NixOS config changes.
allowed-tools: Bash(nixfmt *), Bash(statix *)
---

## Steps

### 1. Format

Run nixfmt on all .nix files (excluding `hardware-configuration.nix`):

```
nixfmt flake.nix configuration.nix modules/*.nix
```

This is equivalent to `nix fmt .` / `just fmt` (the flake specifies `nixfmt-tree` as formatter, and the locally installed `nixfmt` 1.2.0 is the same formatter).

### 2. Lint

```
statix check . --ignore hardware-configuration.nix
```

If statix reports issues, fix them. Common fixes:
- Unused bindings: remove or prefix with `_`
- `with pkgs;` → explicit attribute references
- Eta-reducible functions

### 3. Doc check

!`git diff --name-only HEAD 2>/dev/null || echo ""`

If any `modules/*.nix` files changed, check whether `README.md` and `CLAUDE.md` have corresponding updates. Flag if:
- A new module was added but not listed in README's file structure section
- A new port was added to `flake.nix` but not in README's port reference table
- A new service was added but not in CLAUDE.md's services list

### 4. Report

Summarize: files formatted, lint issues found/fixed, doc gaps flagged.
