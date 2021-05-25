{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # CLI utils
    (aspellWithDicts (d: [d.en]))
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    awscli
    bat           # cat clone with syntax highlighting and git integration
    clojure
    docker-compose
    fd            # alternative to find
    fzf
    gitAndTools.git-annex
    graphviz
    hugo
    jq
    jsonnet
    lazygit       # terminal UI for git
    nixfmt
    nmap
    odt2txt       # for opendocument previews
    openjdk
    plantuml
    poppler_utils # for pdf previews
    python3
    python38Packages.pdftotext
    ranger
    ripgrep
    rmapi
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
  home.stateVersion = "20.03";
}
