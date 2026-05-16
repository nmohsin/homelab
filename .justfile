default:
    just --list

deploy:
    sudo nixos-rebuild switch --flake '.#homelab'

fmt:
    nix fmt .

lint:
    statix check .

up:
    nix flake update

gc:
    sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
    sudo nix-store --verify --check-contents --repair

sops-edit:
    sops secrets/protonvpn.conf

sops-rotate:
    for file in secrets/*; do sops --rotate --in-place "$$file"; done

sops-update:
    for file in secrets/*; do sops updatekeys "$$file"; done
