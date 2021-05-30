{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

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
    httpie
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

    # X utils
    flameshot     # screenshot tool
    hacksaw       # area selection tool
    nomacs        # image viewer
    rofi
    shotgun       # screenshot tool
    xdotool
    xorg.xprop
    xorg.xwininfo
    
    # Communication
    discord
    signal-desktop
    slack
    
    # Fonts
    carlito
    
    # Gnome utils
    gnome3.dconf-editor
    
    # graphics
    gimp
    inkscape
    
    # misc
    brave
    emacs
    exiftool           # cli app for reading, writing and editing meta information
    ffmpegthumbnailer  # video thumbnailer
    kitty
    mediainfo          # unified display of technical and tag data for video and audio files
    qutebrowser        # keyboard driven web browser
    spotify
    standardnotes
    steam-run
    vscode
    wine
    youtube-dl
    
    # pim
    evolutionWithPlugins

    # tools for thought
    drawio
    gnumeric
    libreoffice
    treesheets
    #yed
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
