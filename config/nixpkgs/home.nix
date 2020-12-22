{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # CLI utils
    (aspellWithDicts (d: [d.en]))
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    bat           # cat clone with syntax highlighting and git integration
    clojure
    coursier      # pure scala artifact fetcher
    fd            # alternative to find
    jq
    jsonnet
    lazygit       # terminal UI for git
    nixfmt
    odt2txt
    openjdk
    poppler_utils
    python3
    python38Packages.pdftotext
    ranger
    ripgrep
    sc-im
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
