{ ... }: {
  # system-level: services + polkit, can ONLY live here, home-manager can't declare these
  flake.nixosModules.thunar = { ... }: {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    security.polkit.enable = true;
  };

  # user-level: the actual package, plugins, and defaults
  flake.homeModules.thunar = { pkgs, ... }: {
    home.packages = with pkgs; [
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
    ];

    # make Thunar the default file manager for "open folder" actions
    # from other apps (via the freedesktop mimeapps.list mechanism)
    #xdg.mimeApps.defaultApplications = {
    #  "inode/directory" = [ "thunar.desktop" ];
    #};
  };
}
