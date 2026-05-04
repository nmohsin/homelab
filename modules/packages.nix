{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal utilities
    vim
    tmux
    zellij
    htop
    btop
    tree
    bat
    eza
    fzf
    zoxide

    # Search & find
    fd
    ripgrep

    # Data processing
    jq
    yq-go

    # Network tools
    curl
    wget
    nmap
    traceroute
    iperf3
    tcpdump
    whois

    # Archive tools
    zip
    unzip
    gzip
    gnutar
    p7zip
    xz

    # System tools
    lsof
    pciutils
    usbutils
    dmidecode
    smartmontools
    sysstat
    strace
    file
    which

    # Git extras
    git
    delta
    lazygit

    # Nice to haves
    shellcheck
    entr
    ncdu
    duf
    httpie
  ];

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "fzf" "zoxide" "docker" ];
      theme = "robbyrussell";
    };
  };
}
