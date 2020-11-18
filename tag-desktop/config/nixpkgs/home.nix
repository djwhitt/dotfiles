{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # CLI utils
    bat           # cat clone with syntax highlighting and git integration
    fd            # alternative to find
    lazygit       # terminal UI for git
    tmuxp         # tmux workspace manager

    # X utils
    flameshot     # screenshot tool
    hacksaw       # area selection tool
    nomacs        # image viewer
    rofi
    shotgun       # screenshot tool
    xdotool
    xorg.xprop
    xorg.xwininfo
    
    # graphics
    gimp
    inkscape
    
    # misc
    calibre
    qutebrowser
    wine
    
    # office
    gnumeric
    libreoffice
    thunderbird
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
