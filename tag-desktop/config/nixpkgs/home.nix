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
    lazygit       # terminal UI for git
    nixfmt
    odt2txt
    poppler_utils
    python3
    python38Packages.pdftotext
    ranger
    ripgrep
    sc-im
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
    
    # Gnome utils
    gnome3.dconf-editor
    
    # graphics
    gimp
    inkscape
    
    # misc
    calibre
    exiftool           # cli app for reading, writing and editing meta information
    ffmpegthumbnailer  # video thumbnailer
    mediainfo          # unified display of technical and tag data for video and audio files
    qutebrowser        # keyboard driven web browser
    spotify
    wine
    youtube-dl
    
    # pim
    khal
    vdirsyncer
    
    # office
    gnumeric
    libreoffice
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
