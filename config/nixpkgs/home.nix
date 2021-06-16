{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ## CLI
    
    (aspellWithDicts (d: [d.en]))
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    awscli
    babashka
    bat           # cat clone with syntax highlighting and git integration
    bitwarden-cli
    clojure
    docker-compose
    exiftool      # cli app for reading, writing and editing meta information
    fd            # alternative to find
    fzf           # cli fuzzy finder
    git
    git-lfs
    gitAndTools.git-annex
    httpie
    jq
    lazygit       # terminal UI for git
    mediainfo     # unified display of technical and tag data for video and audio files
    nixfmt        # Nix code formatter
    nmap
    nodejs
    odt2txt       # for opendocument previews
    openjdk
    poppler_utils # for pdf previews
    python3
    python38Packages.pdftotext
    ranger
    ripgrep
    rmapi         # cli tool for interacting with reMarkable cloud
    shellcheck
    tmuxp         # tmux workspace manager
    w3m
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
