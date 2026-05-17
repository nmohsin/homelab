#!/bin/bash
# Pre-commit hook: format and lint all .nix files.
# Exit 0 = allow commit, exit 2 = block commit (stderr shown to Claude).

cd "$(git rev-parse --show-toplevel)" || exit 0

NIX_FILES=$(find . -name '*.nix' ! -name 'hardware-configuration.nix' -type f)
[ -z "$NIX_FILES" ] && exit 0

ERRORS=""

# Check formatting (--check returns non-zero if files need formatting)
if ! nixfmt --check $NIX_FILES 2>/dev/null; then
  # Auto-fix formatting
  nixfmt $NIX_FILES 2>/dev/null
  ERRORS="${ERRORS}nixfmt: files were reformatted — they've been staged automatically.\n"
  git add $NIX_FILES 2>/dev/null
fi

# Lint
LINT_OUTPUT=$(statix check . --ignore hardware-configuration.nix 2>&1)
if [ $? -ne 0 ]; then
  ERRORS="${ERRORS}statix:\n${LINT_OUTPUT}\n"
fi

if [ -n "$ERRORS" ]; then
  echo -e "$ERRORS" >&2
  # If only formatting was fixed (and auto-staged), allow the commit
  if echo "$ERRORS" | grep -q "statix"; then
    exit 2
  fi
fi

exit 0
