---
name: update-docs
description: Review session changes and update README.md and CLAUDE.md to match. Use at the end of a session after making config changes.
---

## Instructions

Review all changes made in this session and update README.md and CLAUDE.md so they accurately reflect the current system state.

## Step 1: Identify what changed

!`git diff main..HEAD --name-only 2>/dev/null; echo "---unstaged---"; git diff --name-only 2>/dev/null; echo "---untracked---"; git ls-files --others --exclude-standard 2>/dev/null`

Read the full diff to understand what changed semantically, not just which files were touched.

## Step 2: Read current docs

Read `README.md` and `CLAUDE.md` in full before proposing any changes.

## Step 3: Check each section against changes

### README.md

| Section | Update when... |
|---------|---------------|
| **Network topology diagram** | Service added/removed, port changed, networking architecture changed |
| **Design decisions** | New architectural pattern or rationale established |
| **Port reference table** | Port added/changed/removed in `flake.nix` `specialArgs.ports`. Table is sorted alphabetically. |
| **File structure** | New module, doc, or secret file added/removed. Descriptions match file purpose. |
| **Procedures** | New operational workflow, new `just` command, changed deploy process |
| **Monitoring** | New monitoring tool, changed alert config |
| **Secrets management** | New secret added, key rotation process changed |
| **External dependencies table** | New external service dependency added |
| **Runbooks list** | New doc added to `docs/` |

### CLAUDE.md

| Section | Update when... |
|---------|---------------|
| **Services** (Native NixOS / Docker bullets) | Service added/removed. Format: service name, module file in parens. |
| **Users and permissions** | User, group, or permission change |
| **Conventions** | New pattern established (e.g., new naming convention, new structural rule) |
| **Gotchas: ZFS** | ZFS config change, new footgun discovered |
| **Gotchas: VPN / ProtonVPN** | VPN config change, networking issue discovered |
| **Gotchas: Docker / Containers** | Container config change, Docker footgun discovered |
| **Gotchas: Services** | Service-specific config issue discovered |
| **Gotchas: Users / Auth** | Auth or user management issue discovered |
| **Gotchas: Monitoring** | Monitoring config change, alert issue discovered |

## Step 4: Propose and apply updates

For each doc:
1. List which sections need updates and why (one line each)
2. If no updates needed, say so explicitly
3. Apply the edits — match the existing style and level of detail in each section
4. Do not add sections that don't exist yet unless the change clearly warrants a new section
5. Do not rewrite sections that are already accurate — only touch what's stale

## Guidelines

- Be precise and concise — match the terse style of existing docs
- Port reference table: keep alphabetically sorted
- File structure: one-line descriptions, match existing indentation
- Gotchas: lead with the constraint or failure mode, not the solution
- Never remove information that's still accurate
- If a change is purely internal (e.g., refactoring without behavior change), docs may not need updating — say so
